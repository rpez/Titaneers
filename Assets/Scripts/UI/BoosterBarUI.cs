using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoosterBarUI : MonoBehaviour
{
    [SerializeField]
    private PlayerMovement playerMovement;

    [SerializeField]
    private BarUI boosterBar;

    // Start is called before the first frame update
    void Start()
    {
        boosterBar = GetComponent<BarUI>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        boosterBar.SetValue(playerMovement.CurrentBoostAmount / playerMovement.MaxBoostAmount);
    }
}
