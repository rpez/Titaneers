using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NavTest : MonoBehaviour
{
    [SerializeField]
    private GameObject _target;

    [SerializeField]
    private Animator animator;

    [SerializeField]
    private NavMeshAgent agent;

    private void Update()
    {
        agent.SetDestination(_target.transform.position);
        animator.SetFloat("Speed", agent.velocity.magnitude);
    }
}
