using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrackPlayer : MonoBehaviour
{
    [SerializeField]
    private float _speed;

    private Transform _target;

    private void Start()
    {
        _target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    private void Update()
    {
        Vector3 distance = _target.position - transform.position;
        transform.position += distance.normalized * Mathf.Min(_speed * Time.deltaTime, distance.magnitude);
    }
}
