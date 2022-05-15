using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [Header("Assign in editor")]
    public GameObject ThreatIndicator;
    public Image AttackCrosshair;
    public Camera Camera;
    public ObjectPool IndicatorPool;
    public Image[] GrappleCharges;
    public GameObject FuelGauge;
    public Image AimCircle;
    public GameObject RestartBtn;
    public GameObject WinningHint;
    public Image BloodScreen;
    public Image LowHealthHue;

    [SerializeField] private float _bloodScreenFadeSpeed = 0.1f;
    [SerializeField] private float _maxThreatDist;
    [SerializeField] private GameObject _rangeIndicator;
    [SerializeField] private GameObject _topRangeIndicator;
    [SerializeField] private RectTransform[] _rangeIndicators;
    [SerializeField] private Image[] _rangeImage;
    [SerializeField] private RawImage _controlGuide;

    // Private variables
    private Color _defaultCrosshairColor;

    private GameObject[] _threats;
    private ObjectPoolUnit[] _threatIndicators;
    private Canvas _canvas;

    private Vector2 _crosshairPos;
    private GameObject _inCrosshair;
    private bool _crosshairTargetSet;
    private bool _guideActive = true;
    private Vector3 _indicatorOffset = new Vector3(-32f, -32f, 0f);
    private float _damageTakenTimer;

    private void Start()
    {
        _defaultCrosshairColor = _rangeImage[0].color;
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
                float distance = Vector3.Distance(_threats[i].transform.position, Camera.transform.position);
                // Check if behind camera
                if (Vector3.Dot(dir, Camera.transform.forward) < 0f || distance > _maxThreatDist)
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

        // update blood screen
        UpdateBloodScreen();
    }


    private void UpdateBloodScreen()
    {
        // recover
        if (Time.time - _damageTakenTimer > 3.0f)
        {
            Color _color = BloodScreen.color;
            _color.a -= _bloodScreenFadeSpeed * Time.deltaTime;
            BloodScreen.color = _color;
        }
    }


    public void DamageTakenEffect(float remainHealth)
    {
        //Debug.LogFormat("Call DamageTakenEffect {0}", remainHealth);
        Color _color = BloodScreen.color;
        _color.a = 1 - remainHealth;
        BloodScreen.color = _color;
        _damageTakenTimer = Time.time;
    }

    public void ChangeCrosshairIleagal(bool withInRange)
    {
        _rangeIndicator.SetActive(false);
        //_topRangeIndicator.SetActive(true);
        //Color color = Color.red;
        //if (!withInRange) color.a = 0.3f;
        //foreach (Image image in _rangeImage)
        //{
        //    image.color = color;
        //}
    }

    public void ActiveIndicator(bool active)
    {
        //_rangeIndicator.SetActive(active);
        AimCircle.enabled = active;
    }

    public void SetControlGuide()
    {
        _guideActive = !_guideActive;
        _controlGuide.enabled = _guideActive;
    }

    public void ChangeIndicator(float anchorX)
    {
        if (anchorX > 0.5f) anchorX += 0.1f;        // reserver margin if without range
        anchorX = Mathf.Clamp(anchorX, 0.5f, 1);
        foreach (RectTransform indicator in _rangeIndicators)
        {
            indicator.pivot = new Vector2(anchorX, indicator.pivot.y);
        }
    }

    public void ResetCrosshairColor(bool withInRange)
    {
        Color color = _defaultCrosshairColor;
        if (!withInRange)
        {
            color = Color.red;
            color.a = 0.3f;
            _topRangeIndicator.SetActive(false);
        }
        else
        {
            _topRangeIndicator.SetActive(true);
        } 
            
        foreach (Image image in _rangeImage)
        {
            image.color = color;
        }
    }

    public void ChangeCrosshairStyle(bool attack)
    {
        _rangeIndicator.SetActive(!attack);
        AttackCrosshair.enabled = attack;
    }

    public void UpdateGrappleCharges(int amount)
    {
        amount = Mathf.Min(amount, GrappleCharges.Length);
        foreach (Image img in GrappleCharges)
        {
            img.color = new Color(1f, 1f, 1f, 0.3f);
        }
        for (int i = 0; i < amount; i++)
        {
            GrappleCharges[i].color = Color.white;
        }
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

    public void ChangeLowHealthEffect(float transparency)
    {
        //Debug.Log(transparency);
        Color _color = LowHealthHue.color;
        _color.a = transparency;
        LowHealthHue.color = _color;
    }

    public void OnRestart()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public void OnDead()
    {
        DOTween.Sequence().AppendInterval(5.0f)
            .AppendCallback(() => RestartBtn.SetActive(true));
    }

    public void OnTitanDead()
    {
        DOTween.Sequence().AppendInterval(20.0f)
            .AppendCallback(() => WinningHint.SetActive(true));
    }
    private IEnumerator Delay(float delay, Action callback)
    {
        yield return new WaitForSeconds(delay);
        callback.Invoke();
    }
}
