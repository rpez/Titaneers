using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Deal Damage
[RequireComponent(typeof(Rigidbody))]//For _trigger works correctly
[RequireComponent(typeof(CapsuleCollider))]
public class HitBox : MonoBehaviour
{
    [SerializeField]
    private bool _continuous = false;//make damage once or keep making damage
    [SerializeField]
    private float _damage;
    [SerializeField]
    private LayerMask _layers;

    private Rigidbody _rb;
    private Collider _trigger;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        if (_rb.useGravity) _rb.useGravity = false;

         _trigger = GetComponent<Collider>();
        if (!_trigger.isTrigger) _trigger.isTrigger = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (!_continuous)
        {
            if ((_layers.value & (int)Mathf.Pow(2, other.gameObject.layer)) == (int)Mathf.Pow(2, other.gameObject.layer))// if the other's layer is included in _layers
            {
                Vector3 toOther = other.transform.position - transform.position;
                HurtBox hurtBox;
                if (hurtBox = other.GetComponent<HurtBox>())
                {
                    DealDamage(hurtBox);
                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if(_continuous)
        {
            if ((_layers.value & (int)Mathf.Pow(2, other.gameObject.layer)) == (int)Mathf.Pow(2, other.gameObject.layer))// if the other's layer is included in _layers
            {
                Vector3 toOther = other.transform.position - transform.position;
                HurtBox hurtBox;
                if (hurtBox = other.GetComponent<HurtBox>())
                {
                    DealDamage(hurtBox);
                }
            }
        }
    }

    private void DealDamage(HurtBox hurtBox)
    {
        hurtBox.ReceiveDamage(_damage);
    }
}
