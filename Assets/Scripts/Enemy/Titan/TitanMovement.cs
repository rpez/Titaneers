using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class TitanMovement : MonoBehaviour
{
    private NavMeshAgent _agent;
    private bool _isStopped;

    private void OnEnable()
    {
        EventManager.FreezeFrame += FreezeForSeconds;

        _agent = GetComponent<NavMeshAgent>();
        _isStopped = true;
    }

    private void OnDisable()
    {
        EventManager.FreezeFrame -= FreezeForSeconds;
    }

    private void FreezeForSeconds(float time)
    {
        StartCoroutine(Freeze(time));
    }

    private IEnumerator Freeze(float time)
    {
        _isStopped = true;

        yield return new WaitForSecondsRealtime(time);

        _isStopped = false;
    }


    public float MoveSpeed
    {
        get
        {
            return _agent.velocity.magnitude;
        }
    }

    private void Update()
    {
        if(!_isStopped)
        {
            if(_agent.remainingDistance<=_agent.stoppingDistance)
            {
                _agent.updateRotation = false;

                //rotate
                Vector3 d = _agent.destination - transform.position;
                d.y = 0;
                Vector3 f = transform.forward;
                f.y = 0;
                float angle = Vector3.Angle(f, d);

                if (angle > _agent.angularSpeed * Time.deltaTime)
                    transform.Rotate(Vector3.up, _agent.angularSpeed * Time.deltaTime);
                else
                    transform.Rotate(Vector3.up, angle);
            }
            else
            {
                _agent.updateRotation = true;
            }
        }
    }

    public void SetDestination(Vector3 destination)
    {
        _agent.isStopped = _isStopped = false;
        _agent.SetDestination(destination);
    }

    public void Stop()
    {
        _agent.isStopped = _isStopped = true;
        _agent.SetDestination(transform.position);
        _agent.velocity = Vector3.zero;
    }
}
