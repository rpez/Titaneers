using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraBehavior : MonoBehaviour
{
    public Transform player;
    private bool shake = false;

    void Update()
    {
        if (!shake) transform.position = player.transform.position;
    }

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
}
