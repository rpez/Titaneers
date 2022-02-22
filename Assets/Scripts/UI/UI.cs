using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [Header("Assign in editor")]
    public GameObject ThreatIndicator;
    public Image Crosshair;
    public Camera Camera;
    public ObjectPool IndicatorPool;

    // Private variables
    private Color _defaultCrosshairColor;

    private GameObject[] _threats;
    private ObjectPoolUnit[] _threatIndicators;

    private void Start()
    {
        _defaultCrosshairColor = Crosshair.color;
        _threats = new GameObject[IndicatorPool.Size];
        _threatIndicators = new ObjectPoolUnit[IndicatorPool.Size];
    }

    private void LateUpdate()
    {
        for (int i = 0; i < _threats.Length; i++)
        {
            if (_threats[i] != null)
            {
                if (_threatIndicators[i] == null)
                {
                    ObjectPoolUnit indicator = IndicatorPool.InitiateFromObjectPool(Vector3.zero, Quaternion.identity, transform);
                    _threatIndicators[i] = indicator;
                }
            }
            else
            {
                if (_threatIndicators[i] != null)
                {
                    Color c = _threatIndicators[i].gameObject.GetComponent<Image>().color;
                    _threatIndicators[i].gameObject.GetComponent<Image>().color = new Color(c.r, c.g, c.b, 0f);
                    _threatIndicators[i].Deactivate();
                    _threatIndicators[i] = null;
                }
            }
        }

        for (int i = 0; i < _threats.Length; i++)
        {
            if (_threats[i] != null)
            {
                Vector3 dir = _threats[i].transform.position - Camera.transform.position;
                if (Vector3.Dot(dir, Camera.transform.forward) < 0f)
                {
                    //_threatIndicators[i].Deactivate();
                    Color c = _threatIndicators[i].gameObject.GetComponent<Image>().color;
                    _threatIndicators[i].gameObject.GetComponent<Image>().color = new Color(c.r, c.g, c.b, 0f);
                    return;
                }

                Color color = _threatIndicators[i].gameObject.GetComponent<Image>().color;
                _threatIndicators[i].gameObject.GetComponent<Image>().color = new Color(color.r, color.g, color.b, 1f);

                Canvas canvas = GetComponent<Canvas>();
                Vector2 screenPoint = RectTransformUtility.WorldToScreenPoint(Camera, _threats[i].transform.position);
                Vector2 result;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent<RectTransform>(), screenPoint, canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : Camera, out result);
                _threatIndicators[i].GetComponent<RectTransform>().anchoredPosition = canvas.transform.TransformPoint(result) + new Vector3(-32f, -32f, 0f);
            }
            else
            {
                if (_threatIndicators[i] != null) Debug.Log("huge gmaing");
            }
        }
    }

    public void ChangeCrosshairColor(Color color)
    {
        Crosshair.color = color;
    }

    public void ResetCrosshairColor()
    {
        Crosshair.color = _defaultCrosshairColor;
    }

    public void StartGame()
    {
        SceneManager.LoadScene("GrayBox");
    }

    public void AddThreat(GameObject obj)
    {
        for (int i = 0; i < _threats.Length; i++)
        {
            if (_threats[i] == null)
            {
                _threats[i] = obj;
                return;
            }
        }
    }
}
