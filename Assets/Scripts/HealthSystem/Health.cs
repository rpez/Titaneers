using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

using UnityEngine.SceneManagement;

public class Health : MonoBehaviour
{
    [Header("Health")]
    [SerializeField]
    private float _maxHealthPoint;
    public float MaxHealthPoint { get => _maxHealthPoint; }

    private float _currentHealthPoint;
    public float CurrentHealthPoint { get => _currentHealthPoint; }

    public float RecoverySpeed = 0.0f;
    public float RecoveryCD = 3.0f;

    [Header("Events")]
    [SerializeField]
    private UnityEvent _addHealthPointEvents;//Invoke when health increase
    [SerializeField]
    private UnityEvent _reduceHealthPointEvents;
    [SerializeField]
    private UnityEvent<float> _damageTakenEvents;
    [SerializeField]
    private UnityEvent _deathEvents;

    private float _damageTakenTimer;
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
        if (IsDead()) return;
        _damageTakenTimer = Time.time;
        _currentHealthPoint -= num;
        _reduceHealthPointEvents.Invoke();
        _damageTakenEvents.Invoke(_currentHealthPoint / MaxHealthPoint);
        if (_currentHealthPoint <= 0)
        {
            _currentHealthPoint = 0f;
            _deathEvents.Invoke();
            // Return to main menu if the player or the titan has been killed
            //SceneManager.LoadScene("menu");
        }
    }

    public bool IsDead()
    {
        return _currentHealthPoint <= 0;
    }

    private void Update()
    {
        if (RecoverySpeed > 0.1f && _currentHealthPoint < _maxHealthPoint)
        {
            if (Time.time - _damageTakenTimer > RecoveryCD)
                _currentHealthPoint += RecoverySpeed * Time.deltaTime;
        }
    }
}
