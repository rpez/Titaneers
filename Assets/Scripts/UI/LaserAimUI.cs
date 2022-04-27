using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LaserAimUI : MonoBehaviour
{
    [SerializeField]
    private RectTransform _canvasRect;
    [SerializeField]
    private Laser _laser;
    [SerializeField]
    private Image _ui;

    private Transform _target;

    // Start is called before the first frame update
    void Start()
    {
        _target = GameObject.FindGameObjectWithTag("Player").transform;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        _ui.enabled = _laser.isAiming; 
        Vector2 viewPos = Camera.main.WorldToViewportPoint(_target.position);
        _ui.rectTransform.anchoredPosition = new Vector2(_canvasRect.rect.width * viewPos.x - _canvasRect.rect.width * 0.5f, _canvasRect.rect.height * viewPos.y - _canvasRect.rect.height * 0.5f);

    }
}
