using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Weakness : MonoBehaviour
{
    [SerializeField]
    private Health _mainHealth;
    [SerializeField]
    private float _damage;
    [SerializeField]
    private UnityEvent _destroiedEvent;

    public void SetDamage(float damage)
    {
        _damage = damage;
    }

    public void Destroied()
    {
        _mainHealth.ReduceHealthPoint(_damage);
        _destroiedEvent.Invoke();
    }
}
