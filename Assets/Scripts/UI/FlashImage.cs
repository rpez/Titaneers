using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlashImage : MonoBehaviour
{
    public Sprite sprite0;
    public Sprite sprite1;

    [SerializeField]
    private Image _image;
    [SerializeField]
    private float _interval;

    private int _point;
    private float _timer;

    private void OnEnable()
    {
        _point = 0;
        _timer = 0f;
        _image.sprite = sprite0;
    }

    private void Update()
    {
        if (_timer > _interval)
        {
            _timer = 0f;
            _point = (_point + 1) % 2;
            _image.sprite = (_point == 0) ? sprite0 : sprite1;
        }
        else
        {
            _timer += Time.deltaTime;
        }
    }
}
