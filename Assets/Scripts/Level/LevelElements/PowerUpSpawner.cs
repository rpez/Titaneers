using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUpSpawner : MonoBehaviour
{
    [SerializeField] protected ObjectPool _powerUpPool;
    [SerializeField] protected Transform[] _spawnPoints;
    [SerializeField] protected Transform _spawnArea;


    private Bounds _bounds;
    // Start is called before the first frame update
    void Start()
    {
        _bounds = new Bounds(_spawnArea.position, _spawnArea.localScale);
        for (int i = 0; i < _powerUpPool.Size; i++)
        {
            Vector3 pos = new Vector3(Random.Range(_bounds.min.x, _bounds.max.x),
                                        Random.Range(_bounds.min.y, _bounds.max.y),
                                        Random.Range(_bounds.min.z, _bounds.max.z));
            _powerUpPool.InitiateFromObjectPool(pos, Quaternion.identity);
        }

    }

    // Update is called once per frame
    void Update()
    {

    }
}
