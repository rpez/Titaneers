using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class Fade : MonoBehaviour
{
    [SerializeField]
    private float _inTime = 1f;
    [SerializeField]
    private float _outTime = 1f;

    public void In()
    {
        GetComponent<Image>().DOFade(0f, _inTime);
    }

    public void Out()
    {
        GetComponent<Image>().DOFade(1f, _outTime);
    }
}
