using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/*
 * Desc: Manege one emitter
 */

public abstract class ProjectileEmitterBase : MonoBehaviour
{
    [SerializeField]
    protected GameObject _target;

    [SerializeField]
    protected ObjectPool _missiles;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public abstract IEnumerator FireProjectile();
}
