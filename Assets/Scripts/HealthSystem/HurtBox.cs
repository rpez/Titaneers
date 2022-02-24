using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Receive Damage
public class HurtBox : MonoBehaviour
{
    [SerializeField]
    private Health _health;
    [SerializeField]
    private bool _instantDeath;

    private void Awake()
    {
        if (!(GetComponent<Rigidbody>()||GetComponentInParent<Rigidbody>()))
        {
            Debug.LogError("Hit Box object doesn't have rigidbody");
        }

        if (!GetComponent<Collider>())
        {
            Debug.LogError("Hit Box object doesn't have Trigger:"+gameObject.name);
        }
    }

    public void ReceiveDamage(float damage)
    {
        if (_instantDeath) _health.ReduceHealthPoint(_health.MaxHealthPoint);
        else _health.ReduceHealthPoint(damage);
    }

}
