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
    public ParticleSystem SpeedLine;

    [Header("Setting")]
    public float VignetteIntensity = 0.3f;
    public Color ImpactFilter = Color.blue;
    public float ImpactFilterTime = 0.3f;
    public float minFov = 70f;
    public float maxFov = 90f;
    public float minDistortion = 0f;
    public float maxDistortion = 0.6f;
    public float maxSpeed = 300f;
    public float minSpeedlineThredhold = 200f;
    public float maxSpeedlineThredhold = 300f;
    public float minSpeedlineRate = 0f;
    public float maxSpeedlineRate = 50f;
    public float minShakeThredhold = 290f;
    public float maxShakeThredhold = 320f;
    public float minShakeIntensity = 0f;
    public float maxShakeIntensity = 5f;


    private LensDistortion _lensDistortionProfile;
    private Vignette _vignetteProfile;
    private ColorAdjustments _colorProfile;
    private float _curVignetteIntensity = 0f;
    private Color _curColor;
    private CinemachineBasicMultiChannelPerlin _noise;
    private CinemachineBasicMultiChannelPerlin _attackNoise;
    private bool _overrideNoise;

    // Start is called before the first frame update
    void Start()
    {
        VolumeProfile.profile.TryGet<LensDistortion>(out _lensDistortionProfile);
        VolumeProfile.profile.TryGet<Vignette>(out _vignetteProfile);
        VolumeProfile.profile.TryGet<ColorAdjustments>(out _colorProfile);
        _curColor = _colorProfile.colorFilter.value;
        _noise = FastMoveCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        _attackNoise = AttackCamera.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();

        SwitchCamera(CameraType.FastMove);
    }

    // Update is called once per frame
    void Update()
    {
        //FoV
        float targetFov = Mathf.Lerp(minFov, maxFov, PlayerControl.CurrentVelocity.magnitude / maxSpeed);
        FastMoveCamera.m_Lens.FieldOfView = Mathf.Lerp(FastMoveCamera.m_Lens.FieldOfView, targetFov, 2 * Time.deltaTime);

        //lensDistortion
        float targetDistortion = Mathf.Lerp(minDistortion, maxDistortion, PlayerControl.CurrentVelocity.magnitude / maxSpeed);
        targetDistortion = Mathf.Lerp(Mathf.Abs(_lensDistortionProfile.intensity.value), targetDistortion, 2 * Time.deltaTime);
        _lensDistortionProfile.intensity.Override(-targetDistortion);

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

        if (!_overrideNoise)
        {
            // Camera Shake
            float shakeRatio = (PlayerControl.CurrentVelocity.magnitude - minShakeThredhold) / (maxShakeThredhold - minShakeThredhold);
            shakeRatio = Mathf.Clamp(shakeRatio, 0, 1.0f);
            float shakeIntensity = Mathf.Lerp(minShakeIntensity, maxShakeIntensity, shakeRatio);
            Noise(shakeIntensity, 2.0f);
        }

        // Speed Line
        float ratio = (PlayerControl.CurrentVelocity.magnitude - minSpeedlineThredhold) / (maxSpeedlineThredhold - minSpeedlineThredhold);
        ratio = Mathf.Clamp(ratio, 0, 1.0f);
        var emission = SpeedLine.emission;
        emission.rateOverTime = Mathf.Lerp(minSpeedlineRate, maxSpeedlineRate, ratio);


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

    public void Noise(float amplitudeGain, float frequencyGain)
    {
        // not good
        _noise.m_AmplitudeGain = amplitudeGain;
        _noise.m_FrequencyGain = frequencyGain;

        _attackNoise.m_AmplitudeGain = amplitudeGain;
        _attackNoise.m_FrequencyGain = frequencyGain;
    }

    public void NoiseImpulse(float amplitudeGain, float frequencyGain, float time)
    {
        Noise(amplitudeGain, frequencyGain);
        _overrideNoise = true;
        StartCoroutine(Delay(time, () => _overrideNoise = false));
    }

    private IEnumerator Delay(float time, Action callback)
    {
        yield return new WaitForSeconds(time);
        callback.Invoke();
    }
}

[System.Serializable]
public class ThresholdSetting
{
    [SerializeField]
    public float Speed;
    [SerializeField]
    public float Intensity;
}