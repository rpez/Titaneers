using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthUI : MonoBehaviour
{
    //temp
    [SerializeField]
    private Text text;

    [SerializeField]
    private Slider slider;

    [SerializeField]
    private Gradient gradient;

    [SerializeField]
    private Image fillImage;

    [SerializeField]
    private Health health;

    private void Update()
    {
        text.text = "Titan HP:" + health.CurrentHealthPoint;
        slider.value = (health.CurrentHealthPoint > 0f ? health.CurrentHealthPoint / health.MaxHealthPoint: 0f);
        fillImage.color = gradient.Evaluate(slider.value);
    }
}
