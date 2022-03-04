using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class DebugUI : MonoBehaviour
{
    public GameObject Player;

    public TMP_Text SpeedText;

    private Rigidbody _playerRb;

    // Start is called before the first frame update
    void Start()
    {
        _playerRb = Player.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        SpeedText.text = "Velocity: " + _playerRb.velocity;
    }
}
