using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class MainMenu : MonoBehaviour
{
    public TMP_InputField MouseSensitivityButtonText;
    public Toggle SkipTutorialToggle;

    // Start is called before the first frame update
    void Start()
    {
        // Must unlock the cursor when main menu launched
        UnityEngine.Cursor.lockState = CursorLockMode.None;
        UnityEngine.Cursor.visible = true;
        SkipTutorialToggle.isOn = SettingsData.Instance.SkipTutorial;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void LoadGame()
    {
        float result;
        bool hasValue = float.TryParse(MouseSensitivityButtonText.text, out result);
        SettingsData.Instance.MouseSensitivity = hasValue ? result : 3.0f;

        SceneManager.LoadScene(SettingsData.Instance.SkipTutorial ? "GrayBox" : "Tutorial");
    }

    public void SetSkipTutorial()
    {
        SettingsData.Instance.SkipTutorial = SkipTutorialToggle.isOn;
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
