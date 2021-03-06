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
    private float _damageInterval = 0.5f;   // continuous damage interval
    [SerializeField]
    private float _damage;
    [SerializeField]
    private LayerMask _layers;

    //private Rigidbody _rb;
    private Collider _trigger;
    private Action<GameObject> _onHitCallback;
    private float _damageTimer;
    public void Initialize(float damage, Action<GameObject> onHitCallback = null)
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
                Vector3 toOther = other.transform.position - transform.position;
                HurtBox hurtBox;
                if (hurtBox = other.GetComponent<HurtBox>())
                {
                    if (_onHitCallback != null) _onHitCallback.Invoke(other.gameObject);    // always invoke
                    DealDamage(hurtBox,_damage);
                    //if (_onHitCallback != null)
                    //{
                        //_onHitCallback = null;
                    //}
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
                if (Time.time - _damageTimer > _damageInterval)
                {
                    Vector3 toOther = other.transform.position - transform.position;
                    HurtBox hurtBox;
                    if (hurtBox = other.GetComponent<HurtBox>())
                    {
                        DealDamage(hurtBox, _damage * _damageInterval);
                    }
                    _damageTimer = Time.time;
                }
            }
        }
    }

    private void DealDamage(HurtBox hurtBox,float damage)
    {
        hurtBox.ReceiveDamage(damage);
    }
}
