using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class PopUp : MonoBehaviour
{
    [SerializeField]
    private AnimationCurve _popCurve;

    [SerializeField]
    private RectTransform _popUI;

    [SerializeField]
    private float _popSize;
    [SerializeField]
    private float _normalSize;
    [SerializeField]
    private float _popTime;

    private float _timer;
    private Coroutine popCoroutine;

    public void PopUI()
    {
        if (gameObject.activeInHierarchy)
        {
            if (popCoroutine != null) StopCoroutine(popCoroutine);
            popCoroutine = StartCoroutine("Pop");
        }
    }

    private void OnEnable()
    {
        _popUI.localScale = Vector3.one * _popSize * 5;
        Image[] images = GetComponentsInChildren<Image>();
        foreach (var image in images)
        {
            Color originalColor = image.color;
            Color startColor = new Color(originalColor.r, originalColor.g, originalColor.b, 0);
            image.color = startColor;
            image.DOColor(originalColor, 2f);
        }
        _popUI.DOScale(_normalSize, 2f);
    }

    private IEnumerator Pop()
    {
        _timer = 0f;
        while (_timer < _popTime)
        {
            _popUI.localScale = Vector3.one * Mathf.Lerp(_normalSize, _popSize, _popCurve.Evaluate(_timer / _popTime));
            _timer += Time.fixedDeltaTime;
            yield return new WaitForFixedUpdate();
        }
    }
}
