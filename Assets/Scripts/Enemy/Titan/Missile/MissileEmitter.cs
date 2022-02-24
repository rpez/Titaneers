using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MissileEmitter : ProjectileEmitterBase
{
    protected enum EmitShape
    {
        Linear,
        Sector,
    }

    [Header("Shape")]
    [SerializeField]
    protected EmitShape _shape = EmitShape.Linear;


    [SerializeField] protected Transform[] _firePoints;
    [SerializeField] protected int _fireRounds;
    [SerializeField] protected float _PosInterval;
    [SerializeField] protected float _RoundInterval;


    [Header("Missile")]
    [SerializeField] private float _speed = 15;
    [SerializeField] private float _rotateSpeed = 95;
    [SerializeField] private float _timeToLive = 20;
    [SerializeField] private bool _isHoming = true;
    [SerializeField] private float _maxDistancePredict = 100;
    [SerializeField] private float _minDistancePredict = 5;
    [SerializeField] private float _maxTimePrediction = 5;
    [SerializeField] private float _deviationAmount = 50;
    [SerializeField] private float _deviationSpeed = 2;
    [SerializeField] private float _damage = 15;



    private float _lastFireTime;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.time - _lastFireTime > 10.0f)
        {
            StartCoroutine(FireProjectile());
            Debug.Log("Fire Projectile");
            _lastFireTime = Time.time;
        }
    }

    public override IEnumerator FireProjectile()
    {
        switch (_shape)
        {
            case EmitShape.Linear:
                {
                    for (int i = 0; i < _fireRounds; i++)
                    {
                        for (int j = 0; j < _firePoints.Length; j++)
                        {
                            ObjectPoolUnit missileUnit = _missiles.InitiateFromObjectPool(_firePoints[j].position, _firePoints[j].rotation);
                            if (missileUnit)
                            {
                                Missile missile = missileUnit.GetComponent<Missile>();
                                if (missile != null)
                                {
                                    missile.SetTarget(_target.GetComponent<Rigidbody>());
                                    missile.SetMovementParam(_speed, _rotateSpeed, _timeToLive,
                                        _isHoming, _maxDistancePredict, _minDistancePredict,
                                        _maxTimePrediction, _deviationAmount, _deviationSpeed, _damage);
                                }
                            }
                            else
                            {
                                Debug.LogError("Can't generate missile");
                            }
                            yield return new WaitForSeconds(_PosInterval);
                        }
                        yield return new WaitForSeconds(_RoundInterval);
                    }
                    break;
                }
            case EmitShape.Sector:
                {
                    break;
                }
            default:
                {
                    break;
                }
        }
    }
}
