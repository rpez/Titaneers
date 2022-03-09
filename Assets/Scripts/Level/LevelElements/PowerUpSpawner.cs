using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUpSpawner : MonoBehaviour
{
    [SerializeField] protected ObjectPool _powerUpPool;
    [SerializeField] protected Transform[] _spawnPoints;

    // Start is called before the first frame update
    void Start()
    {
        foreach (Transform point in _spawnPoints)
        {
            _powerUpPool.InitiateFromObjectPool(point.position, point.rotation);
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
