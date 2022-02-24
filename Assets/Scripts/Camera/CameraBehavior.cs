using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraBehavior : MonoBehaviour
{
    public GameObject Player;
    public CinemachineVirtualCamera vcam;

    public float zoomInLimit;
    public float zoomOutLimit;

    private CinemachineBasicMultiChannelPerlin bmcp;
    private float shakingTimer;
    private float focusingTimer;
    //private bool shake = false;

    void Awake()
    {
        bmcp = vcam.GetCinemachineComponent<CinemachineBasicMultiChannelPerlin>();
        StopShaking();
        StopFocusing();
    }

    void Update()
    {
        shakingTimer -= Time.deltaTime;
        if (shakingTimer <= 0) StopShaking();
        focusingTimer -= Time.deltaTime;
        if (focusingTimer <= 0) StopFocusing();
    }

    public void Zoom(float increment)
    {
        vcam.m_Lens.FieldOfView = Mathf.Clamp(vcam.m_Lens.FieldOfView + increment, zoomInLimit, zoomOutLimit);
    }

    public void Shake(float amplitude, float duration)
    {
        bmcp.m_AmplitudeGain = amplitude;
        shakingTimer = duration;
    }

    public void StopShaking()
    {
        bmcp.m_AmplitudeGain = 0;
        shakingTimer = 0;
    }

    public void Focus(Transform target, float duration)
    {
        //vcam.LookAt = target;
        //focusingTimer = duration;
    }

    public void StopFocusing()
    {
        //vcam.LookAt = Player.transform;
        //transform.rotation = Quaternion.identity;
        //focusingTimer = 0;
    }

    /*
    public IEnumerator Shake(float duration, float magnitude, Vector3 sourcePosition)
    {
        shake = true;

        Vector3 originalPos = transform.localPosition;

        float time = 0.0f;

        while (time < duration)
        {
            transform.position = player.transform.position;
            originalPos = transform.localPosition;
            float distance = Vector3.Distance(sourcePosition, transform.position);
            float multiplier = 1.0f / (distance * distance) * magnitude;

            float x = Random.Range(-1f, 1f) * multiplier;
            float y = Random.Range(-1f, 1f) * multiplier;

            transform.localPosition = originalPos + new Vector3(x, y, 0);

            time += Time.deltaTime;

            yield return null;
        }

        transform.localPosition = originalPos;
        shake = false;
    }
    */
}
