using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Receive Damage
[RequireComponent(typeof(Rigidbody))]//correctly test trigger
[RequireComponent(typeof(CapsuleCollider))]
public class HurtBox : MonoBehaviour
{
    [SerializeField]
    private Health _health;
    [SerializeField]
    private bool _instantDeath;

    public void ReceiveDamage(float damage)
    {
        if (_instantDeath) _health.ReduceHealthPoint(_health.MaxHealthPoint);
        else _health.ReduceHealthPoint(damage);
    }

}
