using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class Flash : MonoBehaviour
{
    private LineRenderer lineRenderer;

    [SerializeField]
    private int pointsCount;
    [SerializeField]
    private float length;
    [SerializeField]
    private float maxOffset;
    [SerializeField]
    private float sinWaveHeight;

    [SerializeField]
    private float frequency;

    private Vector3[] positions;
    private float timer;

    private void Start()
    {
        lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.positionCount = pointsCount;

        timer = 0f;
        positions = new Vector3[pointsCount];
        Sample();

        positions[0] = transform.position;
        positions[pointsCount - 1] = transform.position + transform.forward * length;
    }

    private void Update()
    {
        timer += Time.deltaTime;
        if(timer>=1.0f/frequency)
        {
            timer = 0f;
            Sample();
        }

        for (int i = 0; i < pointsCount; i++)
            lineRenderer.SetPosition(i, positions[i]);
    }

    private void Sample()
    {
        for (int i = 1; i < pointsCount-1; i++)
        {
            float forwardOffset = i * length / pointsCount;

            float verticalOffset;
            float random = Random.Range(-1.0f, 1.0f);
            verticalOffset = random * maxOffset;
            verticalOffset += Mathf.Sin(frequency * Time.time + (float)i / pointsCount * 2 * Mathf.PI)
                * (Time.time % 1)
                * sinWaveHeight;
            Vector3 pos = transform.localPosition + (transform.forward * forwardOffset + transform.up * verticalOffset);
            positions[i] = pos;
        }
    }
}
