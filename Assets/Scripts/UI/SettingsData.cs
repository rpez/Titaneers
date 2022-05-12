using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SettingsData : MonoBehaviour
{
    public float MouseSensitivity;

    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }
}
