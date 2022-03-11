using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BarUI : MonoBehaviour
{
    [SerializeField]
    private Slider slider;

    [SerializeField]
    private Gradient gradient;

    [SerializeField]
    private Image fillImage;

    [SerializeField]
    private float initialValue;

    private void Start()
    {
        slider.value = initialValue;
        fillImage.color = gradient.Evaluate(initialValue);
    }

    public void SetValue(float _value)
    {
        slider.value = _value;
        fillImage.color = gradient.Evaluate(_value);
    }
}
