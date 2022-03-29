using UnityEngine;
using DG.Tweening;
// Script from: https://github.com/affaxltd/rope-tutorial

public class GrapplingRope : MonoBehaviour
{
    [Header("Assign in editor")]
    public GrapplingGun GrapplingGun;

    [Header("Parameters")]
    public AnimationCurve AffectCurve;
    public int Quality;
    public float Damper;
    public float Strength;
    public float Velocity;
    public float WaveCount;
    public float WaveHeight;

    
    // other references
    private Spring _spring;
    private LineRenderer _lr;
    private Vector3 _currentGrapplePosition;

    void Awake()
    {
        _lr = GetComponent<LineRenderer>();
        _spring = new Spring();
        _spring.SetTarget(0);
    }

    //Called after Update
    void Update()
    {
        DrawRope();
    }

    public void OnGrapplePowerUp()
    {
        Debug.Log("OnGrapplePowerUp");
        Color originalColor = _lr.material.GetColor("_EmissiveColor");
        Debug.Log(originalColor);
        _lr.material.SetColor("_EmissiveColor", Color.blue * Mathf.Pow(2, 20));
        // rope shining
        DOTween.To(() => _lr.material.GetColor("_EmissiveColor"), x => _lr.material.SetColor("_EmissiveColor", x), Color.white, 2);
    }

    void DrawRope()
    {
        //If not grappling, don't draw rope
        if (!GrapplingGun.IsLaunched())
        {
            _currentGrapplePosition = GrapplingGun.GunTip.position;
            _spring.Reset();
            if (_lr.positionCount > 0)
                _lr.positionCount = 0;
            return;
        }

        if (_lr.positionCount == 0)
        {
            _spring.SetVelocity(Velocity);
            _lr.positionCount = Quality + 1;
        }

        _spring.SetDamper(Damper);
        _spring.SetStrength(Strength);
        _spring.Update(Time.deltaTime);

        Transform grapplePoint = GrapplingGun.GetGrapplePoint();
        if (grapplePoint == null) return;
        var gunTipPosition = GrapplingGun.GunTip.position;
        var up = Quaternion.LookRotation((grapplePoint.position - gunTipPosition).normalized) * Vector3.up;

        _currentGrapplePosition = Vector3.Lerp(_currentGrapplePosition, grapplePoint.position, Time.deltaTime * 12f);

        for (var i = 0; i < Quality + 1; i++)
        {
            var delta = i / (float)Quality;
            var offset = up * WaveHeight * Mathf.Sin(delta * WaveCount * Mathf.PI) * _spring.Value *
                         AffectCurve.Evaluate(delta);

            _lr.SetPosition(i, Vector3.Lerp(gunTipPosition, _currentGrapplePosition, delta) + offset);
        }
    }
}