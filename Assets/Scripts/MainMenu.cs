using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;
using TMPro;

public class MainMenu : MonoBehaviour
{
    public float DefaultMouseSensitivity;
    public float MinimumMouseSensitivity;
    public float MaximumMouseSensitivity;
    public GameObject MouseSensitivityAdjustment;
    public float MouseSensitivity { get => _mouseSensitivity; }

    public float DefaultGrapplingRange;
    public float MinimumGrapplingRange;
    public float MaximumGrapplingRange;
    public GameObject GrapplingRangeAdjustment;
    public float GrapplingRange { get => _grapplingRange; }

    private GameObject _mouseSensitivityUp;
    private GameObject _mouseSensitivityDown;
    private TextMeshProUGUI _mouseSensitivityButtonTextUGUI;

    private GameObject _grapplingRangeUp;
    private GameObject _grapplingRangeDown;
    private TextMeshProUGUI _grapplingRangeButtonTextUGUI;

    private bool _mouseSensitivityAdjustmentActivated;
    private float _mouseSensitivity;
    private bool _grapplingRangeAdjustmentActivated;
    private float _grapplingRange;

    // Start is called before the first frame update
    void Start()
    {
        _mouseSensitivityAdjustmentActivated = false;
        _mouseSensitivity = DefaultMouseSensitivity;
        _mouseSensitivityUp = MouseSensitivityAdjustment.transform.Find("Up").gameObject;
        _mouseSensitivityDown = MouseSensitivityAdjustment.transform.Find("Down").gameObject;
        _mouseSensitivityButtonTextUGUI = MouseSensitivityAdjustment.transform.Find("Text").gameObject.GetComponent<TextMeshProUGUI>();
        _mouseSensitivityUp.SetActive(false);
        _mouseSensitivityDown.SetActive(false);

        _grapplingRangeAdjustmentActivated = false;
        _grapplingRange = DefaultGrapplingRange;
        _grapplingRangeUp = GrapplingRangeAdjustment.transform.Find("Up").gameObject;
        _grapplingRangeDown = GrapplingRangeAdjustment.transform.Find("Down").gameObject;
        _grapplingRangeButtonTextUGUI = GrapplingRangeAdjustment.transform.Find("Text").gameObject.GetComponent<TextMeshProUGUI>();
        _grapplingRangeUp.SetActive(false);
        _grapplingRangeDown.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void LoadGame(string sceneName)
    {
        DontDestroyOnLoad(this.gameObject);
        SceneManager.LoadScene(sceneName);
    }

    public void AdjustMouseSensitivity(float _delta)
    {
        _mouseSensitivity += _delta;
        if (_mouseSensitivity < MinimumMouseSensitivity)
            _mouseSensitivity = MinimumMouseSensitivity;
        else if (_mouseSensitivity > MaximumMouseSensitivity)
            _mouseSensitivity = MaximumMouseSensitivity;
        _mouseSensitivityButtonTextUGUI.text = _mouseSensitivity.ToString("0.0");
    }

    public void AdjustMouseSensitivity()
    {
        if (_mouseSensitivityAdjustmentActivated)
        {
            _mouseSensitivityButtonTextUGUI.text = "MOUSE SENSITIVITY";
        } else
        {
            _mouseSensitivityButtonTextUGUI.text = _mouseSensitivity.ToString("0.0");
        }

        _mouseSensitivityAdjustmentActivated = !_mouseSensitivityAdjustmentActivated;
        _mouseSensitivityUp.SetActive(_mouseSensitivityAdjustmentActivated);
        _mouseSensitivityDown.SetActive(_mouseSensitivityAdjustmentActivated);
    }

    public void AdjustGrapplingRange(float _delta)
    {
        _grapplingRange += _delta;
        if (_grapplingRange < MinimumGrapplingRange)
            _grapplingRange = MinimumGrapplingRange;
        else if (_grapplingRange > MaximumGrapplingRange)
            _grapplingRange = MaximumGrapplingRange;
        _grapplingRangeButtonTextUGUI.text = _grapplingRange.ToString("0");
    }

    public void AdjustGrapplingRange()
    {
        if (_grapplingRangeAdjustmentActivated)
        {
            _grapplingRangeButtonTextUGUI.text = "GRAPPLING RANGE";
        }
        else
        {
            _grapplingRangeButtonTextUGUI.text = _grapplingRange.ToString("0");
        }

        _grapplingRangeAdjustmentActivated = !_grapplingRangeAdjustmentActivated;
        _grapplingRangeUp.SetActive(_grapplingRangeAdjustmentActivated);
        _grapplingRangeDown.SetActive(_grapplingRangeAdjustmentActivated);
    }
}
