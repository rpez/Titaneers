using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthUI : MonoBehaviour
{
    [SerializeField]
    private BarUI healthBar;

    [SerializeField]
    private Health health;
    [SerializeField]
    private GameObject bg;
    private void Start()
    {
    }

    private void Update()
    {
        float currentHealthPoint = health.CurrentHealthPoint;
        healthBar.SetValue(currentHealthPoint > 0f ? currentHealthPoint / health.MaxHealthPoint: 0f);
        if (currentHealthPoint <= 0)
            bg.SetActive(false);
        else bg.SetActive(true);
    }
}
