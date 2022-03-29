using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewPowerUp : MonoBehaviour
{

    public float ChargeAmount = 2.5f;
    public float RechargeCD = 10f;

    private bool _isCharged = true;
    
    // Start is called before the first frame update
    void Start()
    {
    }

    public void OnGrapple()
    {
        StartCoroutine(OnGrappleEx());
    }

    public IEnumerator OnGrappleEx()
    {
        _isCharged = false;
        // disable VFX
        yield return new WaitForSeconds(RechargeCD);
        // enable VFX
        _isCharged = true;
    }
}
