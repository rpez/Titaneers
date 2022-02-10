using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TriggerEvent : MonoBehaviour
{
    [SerializeField]
    private UnityEvent _triggerEnterEvents;
    [SerializeField]
    private UnityEvent _triggerStayEvents;
    [SerializeField]
    private UnityEvent _triggerExitEvents;

    private void OnTriggerEnter(Collider other)
    {
        _triggerEnterEvents.Invoke();
    }

    private void OnTriggerStay(Collider other)
{
        _triggerStayEvents.Invoke();
    }

    private void OnTriggerExit(Collider other)
{
        _triggerExitEvents.Invoke();
    }
}
