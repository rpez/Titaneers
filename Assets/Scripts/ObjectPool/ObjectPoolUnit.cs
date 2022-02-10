using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ObjectPoolUnit : MonoBehaviour
{
    [SerializeField]
    private UnityEvent _activateEvents;

    private bool _active = true;
    public bool Active { get => _active; }

    private void Start()
    {
        Activate();
    }

    public void Activate()
    {
        _active = true;
        if (_activateEvents != null)
            _activateEvents.Invoke();
    }

    public void Deactivate()
    {
        _active = false;
    }
}
