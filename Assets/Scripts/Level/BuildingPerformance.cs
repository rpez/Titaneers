using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuildingPerformance : MonoBehaviour
{
    [SerializeField]
    private MeshRenderer _renderer;
    [SerializeField]
    private float _dissolveTime;
    [SerializeField]
    private Material _dissolveOriginalMat;

    private Material _normalMat;
    private Material _dissolveMat;

    private void Start()
    {
        _dissolveMat = new Material(_dissolveOriginalMat);
        _dissolveMat.SetFloat("_Progress", 0f);
        _normalMat = _renderer.material;
    }

    private void Update()
    {
        if (_dissolveMat.GetFloat("_Progress") > 0.01f)
        {
            _renderer.material = _dissolveMat;
        }
        else
        {
            _renderer.material = _normalMat;
        }
    }

    public void Destroyed()
    {
        StartCoroutine(DissolveProgress(0f, 1f));
    }

    public void Respawn()
    {
        StartCoroutine(DissolveProgress(1f, 0f));
    }

    private IEnumerator DissolveProgress(float start, float end)
    {
        float timer = 0f;
        while (timer < _dissolveTime)
        {
            timer += Time.deltaTime;
            _dissolveMat.SetFloat("_Progress", Mathf.Lerp(start, end, timer / _dissolveTime));
            yield return new WaitForEndOfFrame();
        }
    }
}
