using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class WeaknessUI : MonoBehaviour
{
    [SerializeField]
    private Health _health;

    //[SerializeField]
    //private Gradient _barColor;
    //[SerializeField]
    //private Gradient _indiColor;

    [SerializeField]
    private Image _hpBar;
    [SerializeField]
    private Image _hpDecreaseIndicator;

    [SerializeField]
    private float _indiDecreaseDelay;
    [SerializeField]
    private float _indiDecreaseTime;

    private float _timer;

    private void Start()
    {
        _timer = 0f;
    }

    private void Update()
    {
        _hpBar.fillAmount = _health.CurrentHealthPoint / _health.MaxHealthPoint;
        //_hpBar.color = _barColor.Evaluate(_hpBar.fillAmount);

        if(_hpDecreaseIndicator.fillAmount> _hpBar.fillAmount)
        {
            if (_timer < _indiDecreaseDelay)
                _timer += Time.deltaTime;
            else
            {
                if(!DOTween.IsTweening(_hpDecreaseIndicator)) _hpDecreaseIndicator.DOFillAmount(_hpBar.fillAmount, _indiDecreaseTime);
            }
        }
        else
        {
            _timer = 0f;
        }
        //_hpDecreaseIndicator.color = _barColor.Evaluate(_hpDecreaseIndicator.fillAmount);
    }
}
