using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WeaknessUI : MonoBehaviour
{
    [SerializeField]
    private Health _health;

    [SerializeField]
    private Gradient _barColor;

    [SerializeField]
    private Image _hpBar;

    private void Update()
    {
        _hpBar.fillAmount = _health.CurrentHealthPoint / _health.MaxHealthPoint;
        _hpBar.color = _barColor.Evaluate(_hpBar.fillAmount);
    }
}
