using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/*
 * reference video: https://www.youtube.com/watch?v=Z6qBeuN-H1M
 */

public class PooledMissile : MonoBehaviour
{
    private enum ProjectileState { Normal, Controlled, Redirected }
    private ProjectileState _state;

    [Header("REFERENCES")]
    [SerializeField] private Rigidbody _rb;
    [SerializeField] private GameObject _explosionPrefab;

    [Header("MOVEMENT")]
    [SerializeField] private float _speed = 15;
    [SerializeField] private float _rotateSpeed = 95;

    [Header("PREDICTION")]
    [SerializeField] private float _maxDistancePredict = 100;
    [SerializeField] private float _minDistancePredict = 5;
    [SerializeField] private float _maxTimePrediction = 5;
    private Vector3 _standardPrediction, _deviatedPrediction;

    [Header("DEVIATION")]
    [SerializeField] private float _deviationAmount = 50;
    [SerializeField] private float _deviationSpeed = 2;

    [Header("ATTACK")]
    [SerializeField] private float _damage = 15;

    // Other
    private Rigidbody _targetRb;
    private GameObject _targetObject;

    public void SetTarget(Rigidbody rb)
    {
        _targetRb = rb;
        _targetObject = rb.gameObject;
        _state = ProjectileState.Normal;
    }

    public void SetTarget(GameObject target)
    {
        _targetRb = null;
        _targetObject = target;
        _state = ProjectileState.Normal;
    }

    public void SetAim(Vector3 direction)
    {
        _rb.MoveRotation(Quaternion.Euler(direction));                
    }

    public void GainControl(GameObject newTarget)
    {
        _rotateSpeed = 200;
        SetTarget(newTarget);
        _state = ProjectileState.Controlled;
    }

    public void Redirect(Vector3 shootPos, Vector3 dir, GameObject newTarget)
    {
        transform.position = shootPos;
        SetAim(dir);
        SetTarget(newTarget);
        _state = ProjectileState.Redirected;
    }
 
    private void FixedUpdate()
    {
        _rb.velocity = transform.forward * _speed;

        var leadTimePercentage = Mathf.InverseLerp(_minDistancePredict, _maxDistancePredict, Vector3.Distance(transform.position, _targetObject.transform.position));

        _standardPrediction = _targetObject.transform.position;

        PredictMovement(leadTimePercentage);

        AddDeviation(leadTimePercentage);

        RotateMissile();
    }

    private void PredictMovement(float leadTimePercentage)
    {
        if (_targetRb == null) return;

        var predictionTime = Mathf.Lerp(0, _maxTimePrediction, leadTimePercentage);

        _standardPrediction = _targetRb.position + _targetRb.velocity * predictionTime;
    }

    private void AddDeviation(float leadTimePercentage)
    {
        var deviation = new Vector3(Mathf.Cos(Time.time * _deviationSpeed), 0, 0);

        var predictionOffset = transform.TransformDirection(deviation) * _deviationAmount * leadTimePercentage;

        _deviatedPrediction = _standardPrediction + predictionOffset;
    }

    private void RotateMissile()
    {
        var heading = _deviatedPrediction - transform.position;

        var rotation = Quaternion.LookRotation(heading);
        _rb.MoveRotation(Quaternion.RotateTowards(transform.rotation, rotation, _rotateSpeed * Time.deltaTime));
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (_state == ProjectileState.Controlled) return;
        if (_state == ProjectileState.Redirected && collision.gameObject.tag == "Player") return;

        if (_explosionPrefab) Instantiate(_explosionPrefab, transform.position, Quaternion.identity);
        if (collision.transform.TryGetComponent<IExplode>(out var ex)) ex.Explode();

        if (collision.transform.GetComponent<BeAttack>() != null)
            collision.transform.GetComponent<BeAttack>().BeAttack(_damage);

        Destroy(gameObject);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(transform.position, _standardPrediction);
        Gizmos.color = Color.green;
        Gizmos.DrawLine(_standardPrediction, _deviatedPrediction);
    }
}