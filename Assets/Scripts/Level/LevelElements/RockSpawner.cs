using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockSpawner : MonoBehaviour
{

    public int RocksPerSec;
    public float BigRocksRatio = 0.1f;
    public float FloatSpeed;
    public float MinScale = 1.0f;
    public float MaxScale = 3.0f;
    public float BigRocksMinScale = 5.0f;
    public float BigRocksMaxScale = 9.0f;
    [SerializeField] protected ObjectPool _rocksPool;
    [SerializeField] protected Transform _spawnArea;
    [SerializeField] protected Transform _destoryArea;


    private Bounds _bounds;
    private float _elapsed = 0f;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        _elapsed += Time.deltaTime;
        if (_elapsed >= 1f)
        {
            // spawn rocks
            _elapsed = _elapsed % 1f;
            _bounds = new Bounds(_spawnArea.position, _spawnArea.localScale);
            for (int i = 0; i < RocksPerSec; i++)
            {
                float scale = Random.Range(MinScale, MaxScale);
                if (i < BigRocksRatio * RocksPerSec)
                {
                    scale = Random.Range(BigRocksMinScale, BigRocksMaxScale);
                }
                Vector3 pos = new Vector3(Random.Range(_bounds.min.x, _bounds.max.x),
                                            Random.Range(_bounds.min.y, _bounds.max.y),
                                            Random.Range(_bounds.min.z, _bounds.max.z));
                ObjectPoolUnit rock = _rocksPool.InitiateFromObjectPool(pos, Random.rotation);
                rock.transform.localScale = new Vector3(scale, scale, scale);
            }
        }

        // move all the rocks
        foreach (ObjectPoolUnit unit in _rocksPool.Units)
        {
            unit.transform.Translate(new Vector3(0, FloatSpeed * Time.deltaTime, 0), Space.World);
            if (unit.transform.position.y > _destoryArea.position.y)
            {
                for (int i = 0; i < unit.transform.childCount; i++)
                {
                    Destroy(unit.transform.GetChild(i).gameObject);
                }
                unit.Deactivate();
            }
        }
    }
}