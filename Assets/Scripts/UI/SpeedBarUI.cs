using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpeedBarUI : MonoBehaviour
{
    [SerializeField]
    private PlayerMovement Player;

    [SerializeField]
    private BarUI speedBar;

    [SerializeField]
    private float maxSpeed;

    // Start is called before the first frame update
    void Start()
    {
        speedBar = GetComponent<BarUI>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        float currentSpeed = Player.CurrentVelocity.magnitude;
        speedBar.SetValue(currentSpeed < maxSpeed ? currentSpeed / maxSpeed : 1f);
    }
}
