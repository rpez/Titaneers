using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileMove : MonoBehaviour
{
    [SerializeField] private float _speed = 15;
    [SerializeField] private GameObject _explosionPrefab;

    private Rigidbody _rb;
    void Start()
    {
        _rb = GetComponent<Rigidbody>(); 
    }

    void FixedUpdate()
    {
        if (_rb != null && _speed != 0)
        {
            _rb.velocity = transform.forward * _speed;
        }    
    }

    private void OnCollisionEnter(Collision collision)
    {
        _speed = 0;
        ContactPoint contact = collision.contacts[0];
        Quaternion rot = Quaternion.FromToRotation(Vector3.up, contact.normal);
        Vector3 pos = contact.point;

        if (_explosionPrefab)
        {
            var explosion = Instantiate(_explosionPrefab, pos, rot);
            Destroy(explosion, 3);
        }

        Destroy(gameObject);
    }
}
