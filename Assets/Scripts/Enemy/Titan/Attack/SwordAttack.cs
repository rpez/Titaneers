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
    private float _randomAreaWidth;
    [SerializeField]
    private float _randomAreaLength;
    [SerializeField]
    private float _swordNumber;

    [SerializeField]
    private ObjectPool _swordPool;

    public IEnumerator SwordWave()
    {
        float timer = 0;
        float speed = _maxDistance / _maxTime;
        float interval = _maxTime / _swordNumber;
        Vector3 pos = transform.position;
        while(timer<_maxTime)
        {
            timer += interval;

            pos += transform.forward * speed * Time.deltaTime;

            Vector3 swordPos = new Vector3(
                Random.Range(pos.x - _randomAreaWidth / 2, pos.x + _randomAreaWidth / 2),
                pos.y,
                pos.z + Mathf.Pow(Random.Range(0, 1), 2) * _randomAreaLength
                );

            _swordPool.InitiateFromObjectPool(swordPos, transform.rotation);

            yield return new WaitForSeconds(interval);
        }
    }
}
