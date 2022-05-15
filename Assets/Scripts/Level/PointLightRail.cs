using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointLightRail : MonoBehaviour
{
    public Transform[] Targets;

    public float Speed = 10f;

    private Vector3 _currentTarget;
    private Vector3 _direction;
    private int _target;
    private float _travelledDistance;
    private float _targetDistance;

    // Start is called before the first frame update
    void Start()
    {
        _currentTarget = Targets[1].position;
        transform.position = Targets[0].position;
        _direction = _currentTarget - transform.position;
        _targetDistance = _direction.magnitude;
        _direction.Normalize();
        _target = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if (_travelledDistance < _targetDistance)
        {
            Vector3 move = _direction * Speed * Time.deltaTime;
            _travelledDistance += move.magnitude;
            transform.Translate(move);
        }
        else
        {
            _target++;
            _currentTarget = Targets[_target % Targets.Length].position;

            _direction = _currentTarget - transform.position;
            _targetDistance = _direction.magnitude;
            _direction.Normalize();
            _travelledDistance = 0;
        }
    }
}
