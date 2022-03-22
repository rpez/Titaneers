using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Deal Damage
public class HitBox : MonoBehaviour
{
    [SerializeField]
    private bool _continuous = false;//make damage once or keep making damage
    [SerializeField]
    private float _damage;
    [SerializeField]
    private LayerMask _layers;

    //private Rigidbody _rb;
    private Collider _trigger;
    private Action _onHitCallback;

    public void Initialize(float damage, Action onHitCallback = null)
    {
        _damage = damage;
        _onHitCallback = onHitCallback;
    }

    private void Awake()
    {
        //_rb = GetComponent<Rigidbody>();
        //if (_rb)
        //{
        //    if (_rb.useGravity) _rb.useGravity = false;
        //}
        //else
        //{
        //    Debug.LogError("Hit Box object doesn't have rigidbody");
        //}

         _trigger = GetComponent<Collider>();
        if (_trigger)
        {
            if (!_trigger.isTrigger) _trigger.isTrigger = true;
        }
        else
        {
            Debug.LogError("Hit Box object doesn't have Trigger");
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log(other.name);
        if (!_continuous)
        {
            if ((_layers.value & (int)Mathf.Pow(2, other.gameObject.layer)) == (int)Mathf.Pow(2, other.gameObject.layer))// if the other's layer is included in _layers
            {
                Debug.Log(other.name+"1");
                Vector3 toOther = other.transform.position - transform.position;
                HurtBox hurtBox;
                if (hurtBox = other.GetComponent<HurtBox>())
                {
                    Debug.Log(other.name + "2");
                    DealDamage(hurtBox);
                    if (_onHitCallback != null) _onHitCallback.Invoke();
                }
            }
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (_continuous)
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
