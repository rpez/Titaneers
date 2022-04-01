using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Health : MonoBehaviour
{
    [Header("Health")]
    [SerializeField]
    private float _maxHealthPoint;
    public float MaxHealthPoint { get => _maxHealthPoint; }

    private float _currentHealthPoint;
    public float CurrentHealthPoint { get => _currentHealthPoint; }

    [Header("Events")]
    [SerializeField]
    private UnityEvent _addHealthPointEvents;//Invoke when health increase
    [SerializeField]
    private UnityEvent _reduceHealthPointEvents;
    [SerializeField]
    private UnityEvent _deathEvents;

    private void Start()
    {
        _currentHealthPoint = _maxHealthPoint;
    }

    public void AddHealthPoint(float num)
    {
        _currentHealthPoint += num;
        _addHealthPointEvents.Invoke();
        if (_currentHealthPoint > _maxHealthPoint) _currentHealthPoint = _maxHealthPoint;
    }

    public void ReduceHealthPoint(float num)
    {
        _currentHealthPoint -= num;
        _reduceHealthPointEvents.Invoke();
        if (_currentHealthPoint <= 0)
        {
            _currentHealthPoint = 0f;
            _deathEvents.Invoke();
        }
    }

    public bool IsDead()
    {
        return _currentHealthPoint <= 0;
    }

    private void Update()
    {
        Debug.Log(_currentHealthPoint);
    }
}
