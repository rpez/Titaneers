using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BarUI : MonoBehaviour
{
    [SerializeField]
    private Gradient gradient;

    [SerializeField]
    private Image fillImage;

    [SerializeField]
    private float maxRatio = 0.25f;

    public void SetValue(float _value)
    {
        fillImage.color = gradient.Evaluate(_value);
        _value *= maxRatio;
        fillImage.fillAmount = _value;
    }
}
