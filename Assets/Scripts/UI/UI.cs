using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [Header("Assign in editor")]
    public Image _crosshair;

    // Private variables
    private Color _defaultCrosshairColor;

    private void Start()
    {
        _defaultCrosshairColor = _crosshair.color;
    }

    public void ChangeCrosshairColor(Color color)
    {
        _crosshair.color = color;
    }

    public void ResetCrosshairColor()
    {
        _crosshair.color = _defaultCrosshairColor;
    }

    public void StartGame()
    {
        SceneManager.LoadScene("GrayBox");
    }
}
