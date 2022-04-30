using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RaisingSword : MonoBehaviour
{
    [SerializeField]
    private float _lowestY;
    [SerializeField]
    private float _highestY;
    [SerializeField]
    private AnimationCurve _raisingCurve;

    [SerializeField]
    private float _raisingTime;

    private float _timer;

    private void Start()
    {
        Init();
    }

    private void Update()
    {
        if (_timer < _raisingTime)
        {
            _timer += Time.deltaTime;
            float y = Mathf.Lerp(_lowestY, _highestY, _raisingCurve.Evaluate(Mathf.Min(_timer / _raisingTime, 1)));
            transform.position = new Vector3(transform.position.x, y, transform.position.z);
        }
    }

    public void Init()
    {
        _timer = 0f;
        transform.position = new Vector3(transform.position.x, _lowestY, transform.position.z);
    }
}
