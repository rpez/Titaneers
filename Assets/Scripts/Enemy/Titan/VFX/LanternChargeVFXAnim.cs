using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LanternChargeVFXAnim : MonoBehaviour
{
    [Header("Charge")]
    [SerializeField]
    private Material chargeMaterial;

    

    // Update is called once per frame
    void Update()
    {
        chargeMaterial.SetTextureOffset("_UnlitColorMap", new Vector2(0, 1 - (Time.time % 1)));
    }
}
