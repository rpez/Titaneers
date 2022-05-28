using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordAttack : MonoBehaviour
{
    [SerializeField]
    private float _maxDistance;
    [SerializeField]
    private float _maxTime;

    [SerializeField]
    private float startOffset = 400f;
    [SerializeField]
    private float _randomAreaWidth;
    [SerializeField]
    private float _randomAreaLength;
    [SerializeField]
    private float _swordNumber;

    [SerializeField]
    private ObjectPool _swordPool;

    private bool _corLock;

    private void Start()
    {
        _corLock = false;
    }


    private void Update()
    {
        //Debug.Log(_corLock);
    }
    public IEnumerator SwordWave()
    {
        if (!_corLock)
        {
            _corLock = true;
            float timer = 0;
            float speed = _maxDistance / _maxTime;
            float interval = _maxTime / _swordNumber;
            Vector3 pos = transform.position + transform.forward * startOffset;
            while (timer < _maxTime)
            {
                timer += interval;

                pos += transform.forward * speed * Time.deltaTime;

                //Vector3 swordPos = new Vector3(
                //    Random.Range(pos.x - _randomAreaWidth / 2, pos.x + _randomAreaWidth / 2),
                //    pos.y,
                //    pos.z + Mathf.Sqrt(Random.Range(0, 1)) * _randomAreaLength
                //    );
                Vector3 swordPos = pos + (transform.right * Random.Range(-_randomAreaWidth / 2, _randomAreaWidth / 2) + transform.forward * Mathf.Sqrt(Random.Range(0, 1)) * _randomAreaLength);

                ObjectPoolUnit u = _swordPool.InitiateFromObjectPool(swordPos, transform.rotation);
                //Debug.Log(u + ":" + Time.realtimeSinceStartup);

                yield return new WaitForSeconds(interval);
            }
            _corLock = false;
        }
    }
}
