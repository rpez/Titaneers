using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LaserAimUI : MonoBehaviour
{
    [SerializeField]
    private RectTransform _canvasRect;
    [SerializeField]
    private Laser _laser;
    [SerializeField]
    private Image _ui;
    [SerializeField]
    private RectTransform _aimSignTrans;
    [SerializeField]
    private float _signRotateSpeed = 60f;

    private Image _signUI;
    private Transform _target;
    private float _timer;

    // Start is called before the first frame update
    void Start()
    {
        _target = GameObject.FindGameObjectWithTag("Player").transform;
        _signUI = _aimSignTrans.GetComponent<Image>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (_laser.isAiming)
        {
            if (!_ui.enabled)
            {
                _ui.enabled = true;
                _timer = 0f;
            }
            Vector2 viewPos = Camera.main.WorldToViewportPoint(_target.position);
            _ui.rectTransform.anchoredPosition = new Vector2(_canvasRect.rect.width * viewPos.x - _canvasRect.rect.width * 0.5f, _canvasRect.rect.height * viewPos.y - _canvasRect.rect.height * 0.5f);
            _timer += Time.fixedDeltaTime;
            _aimSignTrans.localScale = Vector3.one * Mathf.Lerp(1.5f, 1, _timer / _laser.AimTime);
            _aimSignTrans.Rotate(transform.forward, _signRotateSpeed * Time.fixedDeltaTime);
        }
        else
        {
            _ui.enabled = false;
        }
        _signUI.enabled = _ui.enabled;
    }
}
