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
            Debug.LogError("Hurt Box object doesn't have rigidbody");
        }

        if (!GetComponent<Collider>())
        {
            Debug.LogError("Hurt Box object doesn't have Collider:" + gameObject.name);
        }
    }

    public void ReceiveDamage(float damage)
    {
        if (_instantDeath) _health.ReduceHealthPoint(_health.MaxHealthPoint);
        else _health.ReduceHealthPoint(damage);
    }

}
