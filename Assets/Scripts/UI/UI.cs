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

    private List<GameObject> _threats = new List<GameObject>();
    private List<ObjectPoolUnit> _threatIndicators = new List<ObjectPoolUnit>();

    private void Start()
    {
        _defaultCrosshairColor = Crosshair.color;
    }

    private void LateUpdate()
    {
        int diff = _threats.Count - _threatIndicators.Count;
        if (diff > 0)
        {
            for (int i = 0; i < diff; i++)
            {
                ObjectPoolUnit indicator = IndicatorPool.InitiateFromObjectPool(Vector3.zero, Quaternion.identity, transform);
                _threatIndicators.Add(indicator);
            }
        }
        else
        {
            for (int i = 0; i < -diff; i++)
            {
                _threatIndicators[_threatIndicators.Count - i].Deactivate();
            }
        }

        for (int i = 0; i < _threats.Count; i++)
        {
            if (_threats[i] != null)
            {
                //Vector3 dir = _threats[i].transform.position - Camera.transform.position;
                //if (Vector3.Dot(dir, Camera.transform.forward) > 0f)
                //{
                //    _threatIndicators[i].Deactivate();
                //    return;
                //}

                //_threatIndicators[i].Activate();
                Canvas canvas = GetComponent<Canvas>();
                Vector2 screenPoint = RectTransformUtility.WorldToScreenPoint(Camera, _threats[i].transform.position);
                Vector2 result;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent<RectTransform>(), screenPoint, canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : Camera, out result);
                _threatIndicators[i].GetComponent<RectTransform>().anchoredPosition = canvas.transform.TransformPoint(result) + new Vector3(-32f, -32f, 0f);
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
        _threats.Add(obj);
    }
}
