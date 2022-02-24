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
    private Health health;

    private void Update()
    {
        text.text = "Titan HP:" + health.CurrentHealthPoint;
    }
}
