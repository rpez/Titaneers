using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HealthUI : MonoBehaviour
{
    [SerializeField]
    private BarUI healthBar;
    [SerializeField]
    private UI mainUI;
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
        float healthBarValue = currentHealthPoint > 0f ? currentHealthPoint / health.MaxHealthPoint : 0f;
        healthBar.SetValue(healthBarValue);

        if (mainUI)
        {
            mainUI.ChangeLowHealthEffect(Mathf.Pow(1 - healthBarValue, 3f));
        } else
        {
            if (currentHealthPoint <= 0)
                bg.SetActive(false);
            else bg.SetActive(true);
        }
    }
}
