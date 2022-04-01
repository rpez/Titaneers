using System.Collections;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    [Header("Adjust the transition into and out of time slow")]
    public AnimationCurve TransitionCurveIn;
    public AnimationCurve TransitionCurveOut;

    // Other references
    private PostProcessingManager _postProcessingManager;

    // State booleans
    private bool _inTransition;
    private bool _outTransition;
    private bool _frozen;

    // Other Variables
    private float _targetScale;
    private float _defaultFixedDeltaTime;
    private float _currentTransitionTime;
    private float _currentFreezetime;
    private float _currentTimeScale;
    private float _freezeTime;

    private void Awake()
    {
        _defaultFixedDeltaTime = Time.fixedDeltaTime;
        _postProcessingManager = GameObject.Find("Volumes").GetComponent<PostProcessingManager>();
        Time.timeScale = 1f;
    }

    private void Update()
    {
        _currentTransitionTime += Time.unscaledDeltaTime;

        if (_frozen)
        {
            _currentFreezetime += Time.unscaledDeltaTime;
            if (_currentFreezetime >= _freezeTime)
            {
                ResetFreeze();
                _frozen = false;
            }
        }

        if (_inTransition)
        {
            float amount = TransitionCurveIn.Evaluate(_currentTransitionTime);
            Time.timeScale = 1f + amount * (_targetScale - 1f);
            Time.fixedDeltaTime = Time.timeScale * 0.02f;
            _postProcessingManager.SetTimeSlowEffectWeight(amount);

            if (Time.timeScale <= _targetScale)
            {
                _inTransition = false;
                Time.timeScale = _targetScale;
                Time.fixedDeltaTime = Time.timeScale * 0.02f;
            }
        }
        if (_outTransition)
        {
            float amount = TransitionCurveOut.Evaluate(_currentTransitionTime);
            Time.timeScale = amount;
            Time.fixedDeltaTime = Time.timeScale * 0.02f;
            _postProcessingManager.SetTimeSlowEffectWeight(1f - amount);

            if (Time.timeScale >= 1f)
            {
                _outTransition = false;
                Time.timeScale = 1f;
                Time.fixedDeltaTime = _defaultFixedDeltaTime;
                
            }
        }
    }

    public void ToggleTimeScale(float scale, bool active)
    {
        _inTransition = active;
        _outTransition = !_inTransition;
        _targetScale = scale;

        _currentTransitionTime = 0;
    }

    public void ImpactFrame(float time, Color color)
    {
        // TODO: impact effect
        FreezeFrame(time);
    }

    public void FreezeFrame(float time)
    {
        _currentTimeScale = Time.timeScale;
        Time.timeScale = 0f;
        _frozen = true;
        _freezeTime = time;
        _currentFreezetime = 0.0f;
    }

    private void ResetFreeze()
    {
        Time.timeScale = 1f;
    }
}
