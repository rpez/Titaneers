using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class FlashImage : MonoBehaviour
{
    public Sprite Sprite0 { get; set; }
    public Sprite Sprite1 { get; set; }

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
        _image.sprite = Sprite0;
    }

    private void Update()
    {
        if (_timer > _interval)
        {
            _timer = 0f;
            _point = (_point + 1) % 2;
            _image.sprite = (_point == 0) ? Sprite0 : Sprite1;
        }
        else
        {
            _timer += Time.deltaTime;
        }
    }
}
