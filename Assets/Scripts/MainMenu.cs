using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;
using TMPro;

public class MainMenu : MonoBehaviour
{
    public SettingsData Settings;

    //public float DefaultMouseSensitivity;
    //public float MinimumMouseSensitivity;
    //public float MaximumMouseSensitivity;
    //public GameObject MouseSensitivityAdjustment;
    //public float MouseSensitivity { get => _mouseSensitivity; }

    //public float DefaultGrapplingRange;
    //public float MinimumGrapplingRange;
    //public float MaximumGrapplingRange;
    //public GameObject GrapplingRangeAdjustment;
    //public float GrapplingRange { get => _grapplingRange; }

    //private TextMeshProUGUI _mouseSensitivityButtonTextUGUI;
    public TMP_InputField MouseSensitivityButtonText;
    private TMP_InputField _grapplingRangeButtonText;

    private float _mouseSensitivity;
    private float _grapplingRange;

    // Start is called before the first frame update
    void Start()
    {
        // Must unlock the cursor when main menu launched
        UnityEngine.Cursor.lockState = CursorLockMode.None;

        //if (DefaultMouseSensitivity < MinimumMouseSensitivity)
        //    DefaultMouseSensitivity = MinimumMouseSensitivity;
        //else if (DefaultMouseSensitivity > MaximumMouseSensitivity)
        //    DefaultMouseSensitivity = MaximumMouseSensitivity;
        //_mouseSensitivity = Mathf.Round(DefaultMouseSensitivity * 10f) * 0.1f;
        //_mouseSensitivityButtonText = MouseSensitivityAdjustment.GetComponent<TMP_InputField>();
        //_mouseSensitivityButtonText.interactable = false;
        //_mouseSensitivityButtonText.text = _mouseSensitivity.ToString("0.0");

        //if (DefaultGrapplingRange < MinimumGrapplingRange)
        //    DefaultGrapplingRange = MinimumGrapplingRange;
        //else if (DefaultGrapplingRange > MaximumGrapplingRange)
        //    DefaultGrapplingRange = MaximumGrapplingRange;
        //_grapplingRange = Mathf.Round(DefaultGrapplingRange);
        //_grapplingRangeButtonText = GrapplingRangeAdjustment.GetComponent<TMP_InputField>();
        //_grapplingRangeButtonText.interactable = false;
        //_grapplingRangeButtonText.text = _grapplingRange.ToString("0");
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void LoadGame(string sceneName)
    {
        float result = 3.0f;
        float.TryParse(MouseSensitivityButtonText.text, out result);
        Settings.MouseSensitivity = result;

        //DontDestroyOnLoad(this.gameObject);
        SceneManager.LoadScene(sceneName);
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    //public void AdjustMouseSensitivity()
    //{
    //    if (MouseSensitivityButtonText.interactable)
    //    {
    //        MouseSensitivityButtonText.interactable = false;
    //        float val;
    //        try
    //        {
    //            val = float.Parse(MouseSensitivityButtonText.text);
    //        }
    //        catch (FormatException e)
    //        {
    //            val = DefaultMouseSensitivity;
    //        }
    //        if (val < MinimumMouseSensitivity)
    //            _mouseSensitivity = MinimumMouseSensitivity;
    //        else if (val > MaximumMouseSensitivity)
    //            _mouseSensitivity = MaximumMouseSensitivity;
    //        else
    //            _mouseSensitivity = val;
    //        _mouseSensitivity = Mathf.Round(_mouseSensitivity * 10f) * 0.1f;
    //        MouseSensitivityButtonText.text = _mouseSensitivity.ToString("0.0");
    //    } else
    //    {
    //        MouseSensitivityButtonText.interactable = true;
    //    }
    //}

    //public void AdjustGrapplingRange()
    //{
    //    if (_grapplingRangeButtonText.interactable)
    //    {
    //        _grapplingRangeButtonText.interactable = false;
    //        float val;
    //        try
    //        {
    //            val = float.Parse(_grapplingRangeButtonText.text);
    //        }
    //        catch (FormatException e)
    //        {
    //            val = DefaultGrapplingRange;
    //        }
    //        if (val < MinimumGrapplingRange)
    //            _grapplingRange = MinimumGrapplingRange;
    //        else if (val > MaximumGrapplingRange)
    //            _grapplingRange = MaximumGrapplingRange;
    //        else
    //            _grapplingRange = val;
    //        _grapplingRange = Mathf.Round(_grapplingRange);
    //        _grapplingRangeButtonText.text = _grapplingRange.ToString("0");
    //    }
    //    else
    //    {
    //        _grapplingRangeButtonText.interactable = true;
    //    }
    //}
}
