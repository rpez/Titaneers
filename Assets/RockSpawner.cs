using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockSpawner : MonoBehaviour
{

    public int RocksPerSec;
    public float FloatSpeed;
    [SerializeField] protected ObjectPool _rocksPool;
    [SerializeField] protected Transform _spawnArea;
    [SerializeField] protected Transform _destoryArea;


    private Bounds _bounds;
    private float _elapsed = 0f;
    // Start is called before the first frame update
    void Start()
    {
        _bounds = new Bounds(_spawnArea.position, _spawnArea.localScale);
    }

    // Update is called once per frame
    void Update()
    {
        _elapsed += Time.deltaTime;
        if (_elapsed >= 1f)
        {
            // spawn rocks
            _elapsed = _elapsed % 1f;
            for (int i = 0; i < RocksPerSec; i++)
            {
                Vector3 pos = new Vector3(Random.Range(_bounds.min.x, _bounds.max.x),
                                            Random.Range(_bounds.min.y, _bounds.max.y),
                                            Random.Range(_bounds.min.z, _bounds.max.z));
                ObjectPoolUnit rock = _rocksPool.InitiateFromObjectPool(pos, Quaternion.identity);
            }
        }

        // move all the rocks
        foreach (ObjectPoolUnit unit in _rocksPool.Units)
        {
            unit.transform.Translate(new Vector3(0, FloatSpeed * Time.deltaTime, 0), Space.World);
            if (unit.transform.position.y > _destoryArea.position.y)
            {
                unit.Deactivate();
            }
        }
    }
}
