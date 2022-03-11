using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpeedBarUI : MonoBehaviour
{
    [SerializeField]
    private GameObject Player;

    [SerializeField]
    private BarUI speedBar;

    [SerializeField]
    private float maxSpeed;

    private Rigidbody _playerRb;

    // Start is called before the first frame update
    void Start()
    {
        speedBar = GetComponent<BarUI>();
        _playerRb = Player.GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        float currentSpeed = _playerRb.velocity.magnitude;
        speedBar.SetValue(currentSpeed < maxSpeed ? currentSpeed / maxSpeed : 1f);
    }
}
