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

    //Generate Missle
    public void Launch()
    {
        ObjectPoolUnit missile = _missiles.InitiateFromObjectPool(_shootPoint.position, _shootPoint.rotation);
        if(missile)
        {
            missile.GetComponent<Missile>()?.SetTarget(_target.GetComponent<Rigidbody>());
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
