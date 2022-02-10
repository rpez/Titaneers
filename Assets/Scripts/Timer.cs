using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Timer : MonoBehaviour
{
    [SerializeField]
    private float _time;

    private float _timer;
    public float CurrentTimer { get => _timer; }

    [SerializeField]
    private bool _activateOnAwake;
    [SerializeField]
    private bool _autoRestart;

    [SerializeField]
    private UnityEvent _CountZeroEvents;

    private void Awake()
    {
        if (_activateOnAwake) _timer = _time;
        else _timer = 0f;
    }

    // Update is called once per frame
    void Update()
    {
        if (_timer > 0)
        { 
            _timer -= Time.deltaTime;
            if (_timer <= 0)
            {
                _CountZeroEvents.Invoke();
                if (_autoRestart) Restart();
            }
        }
    }

    public void Restart()
    {
        _timer = _time;
    }

    public void ActivateTimer(float _time)
    {
        this._time = _time;
        _timer = _time;
    }

    public bool IsZero()
    {
        return _timer <= 0;
    }
}
