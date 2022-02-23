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
    private Canvas _canvas;

    private Vector2 _crosshairPos;
    private GameObject _inCrosshair;
    private bool _crosshairTargetSet;

    private Vector3 _indicatorOffset = new Vector3(-32f, -32f, 0f);

    private void Start()
    {
        _defaultCrosshairColor = Crosshair.color;
        _threats = new GameObject[IndicatorPool.Size];
        _threatIndicators = new ObjectPoolUnit[IndicatorPool.Size];
        _canvas = GetComponent<Canvas>();
        _crosshairPos = _canvas.renderingDisplaySize * 0.5f;
    }

    private void LateUpdate()
    {
        _crosshairTargetSet = false;
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
                Color color = _threatIndicators[i].GetComponent<Image>().color;
                Vector3 dir = _threats[i].transform.position - Camera.transform.position;
                // Check if behind camera
                if (Vector3.Dot(dir, Camera.transform.forward) < 0f)
                {
                    _threatIndicators[i].GetComponent<Image>().color = new Color(color.r, color.g, color.b, 0f);
                    continue;
                }

                _threatIndicators[i].gameObject.GetComponent<Image>().color = new Color(color.r, color.g, color.b, 1f);

                Vector2 screenPoint = RectTransformUtility.WorldToScreenPoint(Camera, _threats[i].transform.position);
                Vector2 result;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(GetComponent<RectTransform>(), screenPoint, _canvas.renderMode == RenderMode.ScreenSpaceOverlay ? null : Camera, out result);

                RectTransform rt = _threatIndicators[i].GetComponent<RectTransform>();
                rt.anchoredPosition = _canvas.transform.TransformPoint(result) + _indicatorOffset;

                // Check if crosshair within indicator
                if ((rt.anchoredPosition - _crosshairPos + new Vector2(32f, 32f)).magnitude < 32f)
                {
                    // If there exists a stored object already
                    if (_inCrosshair != null)
                    {
                        // If current object is closer, continue
                        if ((_inCrosshair.transform.position - Camera.transform.position).magnitude
                            > (_threats[i].transform.position - Camera.transform.position).magnitude) continue;
                    }
                    // Set crosshair object
                    _inCrosshair = _threats[i];
                    _crosshairTargetSet = true;
                }
            }
            else
            {
                if (_threatIndicators[i] != null) Debug.LogWarning("Indicator for a non-existing threat exists");
            }
        }
        if (!_crosshairTargetSet)
        {
            _inCrosshair = null;
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

    public GameObject GetCrosshairTarget()
    {
        return _inCrosshair;
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
