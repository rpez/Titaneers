using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SimpleImageAnim : MonoBehaviour
{
    [SerializeField]
    private Image _image;
    [SerializeField]
    private Sprite[] _sprites;
    [SerializeField]
    private float _interval;
    [SerializeField]
    private bool _loop;

    private int point;
    private float timer;

    private void OnEnable()
    {
        point = 0;
        timer = 0f;
        _image.sprite = _sprites[point];
    }

    private void Update()
    {
        if (point <= _sprites.Length)
        {
            if(timer>_interval)
            {
                timer = 0f;
                point = (_loop) ? (point + 1) % _sprites.Length : (point + 1);
                _image.sprite = _sprites[point];
            }
            else
            {
                timer += Time.deltaTime;
            }
        }
    }
}
