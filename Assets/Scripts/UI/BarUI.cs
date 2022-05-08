using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BarUI : MonoBehaviour
{
    [SerializeField]
    private Gradient gradient;

    [SerializeField]
    private Image fillImage;

    [SerializeField]
    private Image fadeImage;

    [SerializeField]
    private float maxRatio = 0.25f;


    public void SetValue(float _value)
    {
        fillImage.color = gradient.Evaluate(_value);
        _value *= maxRatio;
        fillImage.fillAmount = _value;

        if (fadeImage)
        {
            DOTween.Sequence()
                .AppendInterval(1.0f)
                .Append(fadeImage.DOFillAmount(_value, 1.0f));
        }
    }

}
