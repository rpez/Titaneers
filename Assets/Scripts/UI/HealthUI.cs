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
    private BarUI healthBar;

    [SerializeField]
    private Health health;

    private void Start()
    {
        healthBar = GetComponent<BarUI>();
    }

    private void Update()
    {
        float currentHealthPoint = health.CurrentHealthPoint;
        text.text = "Titan HP:" + Mathf.Round(currentHealthPoint);
        healthBar.SetValue(currentHealthPoint > 0f ? currentHealthPoint / health.MaxHealthPoint: 0f);
    }
}
