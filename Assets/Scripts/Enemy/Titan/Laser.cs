using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : MonoBehaviour
{
    [SerializeField]
    private Transform _shootPoint;

    [SerializeField]
    private LineRenderer _lineRenderer;
    [SerializeField]
    private float maxLength = 10000f;

    [SerializeField]
    private float _aimTime;
    [SerializeField]
    private float _aimRayWidth;

    [SerializeField]
    private float _shootTime;
    [SerializeField]
    private float _shootRayWidth;
    [SerializeField]
    private CapsuleCollider _hitbox;

    [SerializeField]
    private LayerMask _layers;

    private Transform _target;

    private void OnEnable()
    {
        _target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    private  IEnumerator ShootLaser()
    {
        _lineRenderer.SetPosition(0, _shootPoint.position);

        //Aim
        float timer = _aimTime;
        while (timer > 0)
        {
            timer -= Time.deltaTime;
            _shootPoint.LookAt(_target);

            RaycastHit hit;
            if (Physics.Raycast(_shootPoint.position, _shootPoint.forward, out hit, maxLength, _layers))
            {
                _lineRenderer.SetPosition(1, hit.point);
                _lineRenderer.startWidth = _lineRenderer.endWidth = _aimRayWidth;
            }
            else
            {
                _lineRenderer.SetPosition(1, _shootPoint.position + _shootPoint.forward * maxLength);
            }

            yield return new WaitForEndOfFrame();
        }

        timer = _shootTime;

        while (timer > 0)
        {
            timer -= Time.deltaTime;

            _lineRenderer.SetPosition(1, _shootPoint.position + _shootPoint.forward * maxLength);
            _lineRenderer.startWidth = _lineRenderer.endWidth = _shootRayWidth;

            _hitbox.radius = _shootRayWidth / 2;
            _hitbox.height = maxLength;
        }

        _hitbox.radius = _hitbox.height = 0f;
        _lineRenderer.SetPosition(1, _shootPoint.position);
    }
}
