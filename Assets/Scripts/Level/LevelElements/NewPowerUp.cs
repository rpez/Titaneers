using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewPowerUp : MonoBehaviour
{
    public bool IsPowerUp = true;
    public float ChargeAmount = 2.5f;
    public float RechargeCD = 10f;

    private bool _isCharged = true;
    private Material _lightMat;
    private Color _originalColor;

    public bool IsCharged { get => _isCharged; }
    // Start is called before the first frame update
    void Start()
    {
        _lightMat = GetComponent<MeshRenderer>().material;
        _originalColor = _lightMat.GetColor("_EmissiveColor");
        if (IsPowerUp)
            _lightMat.SetColor("_EmissiveColor", _originalColor * Mathf.Pow(2, 6));
    }

    public void OnGrapple()
    {
        if (!IsPowerUp) return;
        StartCoroutine(OnGrappleEx());
    }

    public IEnumerator OnGrappleEx()
    {
        _isCharged = false;
        // disable VFX
        _lightMat.SetColor("_EmissiveColor", _originalColor);
        yield return new WaitForSeconds(RechargeCD);
        // enable VFX
        _lightMat.SetColor("_EmissiveColor", _originalColor * Mathf.Pow(2, 6));
        _isCharged = true;
    }
}
