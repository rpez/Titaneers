using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using DG.Tweening;

public class CameraBehaviour : MonoBehaviour
{
    [Header("Reference")]
    public PlayerMovement PlayerControl;
    public Volume VolumeProfile;

    [Header("Setting")]
    public MotionBlurThreshold[] MotionBlurSettings;
    public float VignetteIntensity = 0.3f;
    public Color ImpactFilter = Color.blue;
    public float ImpactFilterTime = 0.3f;


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
    }

    // Update is called once per frame
    void Update()
    {
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
