using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class TimeManager : MonoBehaviour
{
    [Header("Adjust the transition into and out of time slow")]
    public AnimationCurve TransitionCurveIn;
    public AnimationCurve TransitionCurveOut;

    public string[] PhasedActions;
    public FlashImage TutorialText;

    // Other references
    private PostProcessingManager _postProcessingManager;

    // State booleans
    private bool _inTransition;
    private bool _outTransition;
    private bool _frozen;
    private bool _conditional;
    private bool _phased;

    // Other Variables
    private float _targetScale;
    private float _defaultFixedDeltaTime;
    private float _currentTransitionTime;
    private float _currentFreezetime;
    private float _currentTimeScale;
    private float _freezeTime;

    private bool _pollForInput;
    private string _requiredKey = "";
    private int[] _keyValues;
    private InputAction _keyAction;
    private int _phaseIndex;

    private void Awake()
    {
        _defaultFixedDeltaTime = Time.fixedDeltaTime;
        _postProcessingManager = GameObject.Find("Volumes").GetComponent<PostProcessingManager>();
        _keyValues = (int[])System.Enum.GetValues(typeof(KeyCode));
    }

    private void Update()
    {
        _currentTransitionTime += Time.unscaledDeltaTime;

        if (_pollForInput)
        {
            _keyAction.performed += _ =>
            {
                RequiredKeyPressed();
            };
        }

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
                _postProcessingManager.SetTimeSlowEffectWeight(0f);
            }
        }
    }

    public void ToggleTimeScale(float scale, bool active)
    {
        _inTransition = active;
        _outTransition = !_inTransition;
        _targetScale = scale;

        _currentTransitionTime = 0f;
    }

    public void ImpactFrame(float time, Color color)
    {
        // TODO: impact effect
        FreezeFrame(time);
    }

    public void FreezeFrame(float time)
    {
        //_currentTimeScale = Time.timeScale;
        //Time.timeScale = 0f;
        //_frozen = true;
        //_freezeTime = time;
        //_currentFreezetime = 0.0f;
    }
    
    private void RequiredKeyPressed()
    {
        if (_conditional)
        {
            StopConditionalFreeze();
        }
        else if (_phased)
        {
            if (_phaseIndex >= PhasedActions.Length - 1) StopPhasedFreeze();
            AdvancePhasedFreeze();
        }
    }

    public void StartConditionalFreeze(string key)
    {
        ToggleTimeScale(0.01f, true);
        _pollForInput = true;
        _conditional = true;
        _requiredKey = key;
        _currentFreezetime = 0.0f;
        _keyAction = new InputAction(binding: key);
        _keyAction.Enable();
    }

    public void StopConditionalFreeze()
    {
        ToggleTimeScale(0.01f, false);
        _pollForInput = false;
        _conditional = false;
        _requiredKey = "";
        _keyAction.Disable();
    }

    public void StartPhasedFreeze(int index = 0)
    {
        ToggleTimeScale(0.05f, true);
        _pollForInput = true;
        _phased = true;
        _currentFreezetime = 0.0f;
        _phaseIndex = 0;

        AdvancePhasedFreeze();
    }

    public void AdvancePhasedFreeze(int index = 0)
    {
        _keyAction = new InputAction(binding: PhasedActions[_phaseIndex]);
        _keyAction.Enable();
        _phaseIndex++;

        if (TutorialText) TutorialText.UpdateText();
    }
        
    public void StopPhasedFreeze()
    {
        _pollForInput = false;
        _phased = false;
        _requiredKey = "";
        _keyAction.Disable();

        ToggleTimeScale(0.05f, false);
    }

    private void ResetFreeze()
    {
        Time.timeScale = _currentTimeScale;
        _postProcessingManager.SetTimeSlowEffectWeight(0f);
    }
}
