using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class UI : MonoBehaviour
{
    [Header("Assign in editor")]
    public GameObject ThreatIndicator;
    public Image Crosshair;
    public Camera _camera;

    // Private variables
    private Color _defaultCrosshairColor;

    private List<GameObject> _threats = new List<GameObject>();
    private List<GameObject> _threatIndicators = new List<GameObject>();

    private void Start()
    {
        _defaultCrosshairColor = Crosshair.color;
    }

    private void Update()
    {
        //int diff = _threats.Count - _threatIndicators.Count;
        //if (diff > 0)
        //{
        //    for (int i = 0; i < diff; i++)
        //    {
        //        GameObject indicator = GameObject.Instantiate(ThreatIndicator);
        //        indicator.transform.SetParent(transform);
        //        _threatIndicators.Add(indicator);
        //    }
        //}
        //else
        //{
        //    for (int i = 0; i < -diff; i++)
        //    {
        //        _threatIndicators.Remove(_threatIndicators[_threatIndicators.Count + diff]);
        //    }
        //}

        //for (int i = 0; i < _threats.Count; i++)
        //{
        //    if (_threats[i] != null)
        //    {
        //        _threatIndicators[i].GetComponent<RectTransform>().anchoredPosition = _camera.WorldToScreenPoint(_threats[i].transform.position);
        //    }
        //}
    }

    public void ChangeCrosshairColor(Color color)
    {
        Crosshair.color = color;
    }

    public void ResetCrosshairColor()
    {
        Crosshair.color = _defaultCrosshairColor;
    }

    public void StartGame()
    {
        SceneManager.LoadScene("GrayBox");
    }

    public void AddThreat(GameObject obj)
    {
        _threats.Add(obj);
    }
}
