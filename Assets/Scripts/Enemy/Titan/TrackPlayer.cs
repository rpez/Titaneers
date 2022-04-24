using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrackPlayer : MonoBehaviour
{
    [SerializeField]
    private float _speed;
    [SerializeField]
    private float _maxDistance;

    private Transform _target;

    private void Start()
    {
        _target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    private void FixedUpdate()
    {
        Vector3 distance = _target.position - transform.position;
        if (distance.magnitude <= _maxDistance)
            transform.position += distance.normalized * Mathf.Min(_speed * Time.deltaTime, distance.magnitude);
        else
            transform.position = _target.position - distance.normalized * _maxDistance;
    }
}
