using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tracking : MonoBehaviour
{
    public Transform target;

    [SerializeField]
    private float rotateSpeed;

    private void Update()
    {
        Vector3 toTarget = target.position - transform.position;
        Quaternion roAngle = Quaternion.FromToRotation(toTarget, transform.forward);
        Vector3 rotation = Quaternion.Normalize(roAngle).eulerAngles * rotateSpeed;
        transform.Rotate(rotation, Space.World);
    }
}
