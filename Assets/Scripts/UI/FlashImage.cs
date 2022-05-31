using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class FlashImage : MonoBehaviour
{
    public Sprite ButtonSprite { get; set; }
    public string TextHint { get; set; }

    [SerializeField]
    public Sprite _transparentSprite;
    [SerializeField]
    private Image _image;
    [SerializeField]
    private TMP_Text _text;

    public void UpdateText()
    {
        _text.text = TextHint;
        _image.sprite = ButtonSprite;
    }

    private void OnEnable()
    {
        UpdateText();
    }

    private void OnDisable()
    {
        _text.text = "";
        _image.sprite = _transparentSprite;
    }
}
