using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using DG.Tweening;
using Cinemachine;
using System;

public enum CameraType
{
    //Follow,
    FastMove,
    Attack,
}


public class CameraBehaviour : MonoBehaviour
{
    [Header("Reference")]
    public PlayerMovement PlayerControl;
    public Volume VolumeProfile;
    //public CinemachineVirtualCamera FollowCamera;
    public CinemachineVirtualCamera FastMoveCamera;
    public CinemachineVirtualCamera AttackCamera;

    [Header("Setting")]
    public MotionBlurThreshold[] MotionBlurSettings;
    public float VignetteIntensity = 0.3f;
    public Color ImpactFilter = Color.blue;
    public float ImpactFilterTime = 0.3f;
    public float minFov = 70f;
    public float maxFov = 90f;
    public float maxSpeed = 300f;

    private MotionBlur _motionBlurProfile;
    private Vignette _vignetteProfile;
    private ColorAdjustments _colorProfile;
    private float _curVignetteIntensity = 0f;
    private Color _curColor;
    // Start is called before the first frame update
    void Start()
    {
        VolumeProfile.profile.TryGet<MotionBlur>(out _motionBlurProfile);
        VolumeProfile.profile.TryGet<Vignette>(out _vignetteProfile);
        VolumeProfile.profile.TryGet<ColorAdjustments>(out _colorProfile);
        _curColor = _colorProfile.colorFilter.value;
        SwitchCamera(CameraType.FastMove);
    }

    // Update is called once per frame
    void Update()
    {
        //FoV
        float targetFov = Mathf.Lerp(minFov, maxFov, PlayerControl.CurrentVelocity.magnitude / maxSpeed);
        FastMoveCamera.m_Lens.FieldOfView = Mathf.Lerp(FastMoveCamera.m_Lens.FieldOfView, targetFov, 2 * Time.deltaTime);

        //motion blur
        for (int i = MotionBlurSettings.Length - 1; i >= 0; i--)
        {
            if (PlayerControl.CurrentVelocity.magnitude > MotionBlurSettings[i].Speed)
            {
                _motionBlurProfile.intensity.Override(MotionBlurSettings[i].Intensity);
                break;
            }
        }

        //vignette
        if (PlayerControl.IsBoosting)
        {
            _curVignetteIntensity = Mathf.Lerp(_curVignetteIntensity, VignetteIntensity, Time.deltaTime);
            _vignetteProfile.intensity.Override(_curVignetteIntensity);
        }
        else
        {
            _curVignetteIntensity = Mathf.Lerp(_curVignetteIntensity, 0, Time.deltaTime);
            _vignetteProfile.intensity.Override(_curVignetteIntensity);
        }
    }

    public void OnAttack()
    {
        StartCoroutine(AddColorFilter());
        SwitchCamera(CameraType.Attack);
    }
    public void OnAttackEnd()
    {
        SwitchCamera(CameraType.FastMove);
    }

    public void SwitchCamera(CameraType type)
    {
        switch (type)
        {
            //case CameraType.Follow:
            //    FollowCamera.Priority = 1;
            //    FastMoveCamera.Priority = 0;
            //    AttackCamera.Priority = 0;
            //    break;
            case CameraType.FastMove:
                //FollowCamera.Priority = 0;
                FastMoveCamera.Priority = 1;
                AttackCamera.Priority = 0;
                break;
            case CameraType.Attack:
                //FollowCamera.Priority = 0;
                FastMoveCamera.Priority = 0;
                AttackCamera.Priority = 1;
                break;
            default:
                break;
        }
    }

    public IEnumerator AddColorFilter()
    {
        float timeElapsed = 0;
        while (timeElapsed < ImpactFilterTime / 2)
        {
            timeElapsed += Time.deltaTime;
            _curColor = Color.Lerp(_curColor, ImpactFilter, 2 * timeElapsed / ImpactFilterTime);
            _colorProfile.colorFilter.Override(_curColor);
            yield return null;
        }
        // facade
        while (timeElapsed < ImpactFilterTime)
        {
            timeElapsed += Time.deltaTime;
            _curColor = Color.Lerp(_curColor, Color.white, timeElapsed / ImpactFilterTime);
            _colorProfile.colorFilter.Override(_curColor);
            yield return null;
        }
        _colorProfile.colorFilter.Override(Color.white);
    }

}

