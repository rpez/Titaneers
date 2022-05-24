using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeLevel : MonoBehaviour
{
    public void Load(string levelName)
    {
        SettingsData.Instance.SkipTutorial = true;
        SceneManager.LoadScene(levelName);
    }
}
