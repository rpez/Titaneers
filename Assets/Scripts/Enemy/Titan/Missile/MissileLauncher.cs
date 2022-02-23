using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MissileLauncher : MonoBehaviour
{
    [SerializeField]
    private GameObject _target;

    [SerializeField]
    private ObjectPool _missiles;

    [SerializeField]
    private Transform _shootPoint;

    private CameraBehavior _playerCameraBehavior;

    void Start()
    {
        _playerCameraBehavior = FindObjectOfType<CameraBehavior>();
    }

    //Generate Missle
    public void Launch()
    {
        ObjectPoolUnit missile = _missiles.InitiateFromObjectPool(_shootPoint.position, _shootPoint.rotation);
        if(missile)
        {
            missile.GetComponent<Missile>()?.SetTarget(_target.GetComponent<Rigidbody>());
            _playerCameraBehavior.Focus(_shootPoint, 0.4f);
        }
        else
        {
            Debug.LogError("Can't generate missile");
        }
    }

    public void ChangeTarget(GameObject newTarget)
    {
        _target = newTarget;
    }
}
