using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PopUp : MonoBehaviour
{
    [SerializeField]
    private AnimationCurve _popCurve;

    [SerializeField]
    private RectTransform _popUI;

    private float _timer;
    private Coroutine popCoroutine;

    public void PopUI()
    {
        if (popCoroutine != null) StopCoroutine(popCoroutine);
        popCoroutine = StartCoroutine("Pop");
    }

    private IEnumerator Pop()
    {
        _timer = 0f;
        float length = _popCurve.keys[_popCurve.length - 1].time;
        while (_timer < length)
        {
            _popUI.localScale = Vector3.one * _popCurve.Evaluate(_timer);
            _timer += Time.fixedDeltaTime;
            yield return new WaitForEndOfFrame();
        }
    }
}
