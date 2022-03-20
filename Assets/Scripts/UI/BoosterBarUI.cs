using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BoosterBarUI : MonoBehaviour
{
    [SerializeField]
    private PlayerMovement playerMovement;

    [SerializeField]
    private Image[] boosterBarCells;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        int enabledCellAmount = Mathf.FloorToInt(Mathf.Min(playerMovement.CurrentBoostAmount, boosterBarCells.Length));
        for (int i = boosterBarCells.Length - 1; i >= 0; --i)
            boosterBarCells[i].enabled = i < enabledCellAmount;
    }
}
