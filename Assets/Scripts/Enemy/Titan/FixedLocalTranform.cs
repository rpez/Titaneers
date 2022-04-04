using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class FixedLocalTranform : MonoBehaviour
{
    public Vector3 localPosition;
    public Quaternion localRotation;
    public Vector3 localScale;

    private void OnEnable()
    {
        localPosition = transform.localPosition;
        localRotation = transform.localRotation;
        localScale = transform.localScale;
    }

    void Update()
    {
        transform.localPosition = localPosition;
        transform.localRotation = localRotation;
        transform.localScale = localScale;
    }
}
