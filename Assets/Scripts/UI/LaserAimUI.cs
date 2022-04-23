using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LaserAimUI : MonoBehaviour
{
    [SerializeField]
    private RectTransform canvasRect;
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
        _ui.rectTransform.anchoredPosition = new Vector2(canvasRect.rect.width * viewPos.x - canvasRect.rect.width * 0.5f, canvasRect.rect.height * viewPos.y - canvasRect.rect.height * 0.5f);

    }
}
