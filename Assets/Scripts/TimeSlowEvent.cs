using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TimeSlowEvent : MonoBehaviour
{
    [SerializeField]
    private UnityEvent _timeSlowStartEvents;
    [SerializeField]
    private UnityEvent _timeSlowStopEvents;

    private bool _isTimeSlow;

    private void Start()
    {
        _isTimeSlow = false;
    }

    private void Update()
    {
        if (Time.timeScale < 1f && !_isTimeSlow)
        {
            _isTimeSlow = true;
            _timeSlowStartEvents.Invoke();
        }
        if (Time.timeScale >= 0.99f && _isTimeSlow)
        {
            _isTimeSlow = false;
            _timeSlowStopEvents.Invoke();
        }
    }
}
