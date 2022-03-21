using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BoosterBarUI : MonoBehaviour
{
    [SerializeField]
    private PlayerMovement playerMovement;

    [SerializeField]
    private BarUI boostBar;

    [SerializeField]
    private float maxUIBoost;

    //[SerializeField]
    //private Image[] boosterBarCells;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        float currentBoost = playerMovement.CurrentBoostAmount;
        boostBar.SetValue(currentBoost < maxUIBoost ? currentBoost / maxUIBoost : 1f);
        //int enabledCellAmount = Mathf.FloorToInt(Mathf.Min(playerMovement.CurrentBoostAmount, boosterBarCells.Length));
        //for (int i = boosterBarCells.Length - 1; i >= 0; --i)
        //    boosterBarCells[i].enabled = i < enabledCellAmount;
    }
}
