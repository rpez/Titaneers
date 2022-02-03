using System.Collections;
using UnityEngine;

public class TimeManager : MonoBehaviour
{
    [Header("Adjust the transition into and out of time slow")]
    public AnimationCurve TransitionCurveIn;
    public AnimationCurve TransitionCurveOut;

    // Other references
    private PostProcessingManager _postProcessingManager;

    // State boolenas
    private bool _inTransition;
    private bool _outTransition;

    // Other Variables
    private float _targetScale;
    private float _defaultFixedDeltaTime;
    private float _currentTime;

    private void Awake()
    {
        _defaultFixedDeltaTime = Time.fixedDeltaTime;
        _postProcessingManager = GameObject.Find("Volumes").GetComponent<PostProcessingManager>();
    }

    private void Update()
    {
        _currentTime += Time.unscaledDeltaTime;

        if (_inTransition)
        {
            float amount = TransitionCurveIn.Evaluate(_currentTime);
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
            float amount = TransitionCurveOut.Evaluate(_currentTime);
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

        _currentTime = 0;
    }
}
