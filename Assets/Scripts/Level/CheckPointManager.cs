using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckPointManager : MonoBehaviour
{
    [SerializeField]
    private PlayerMovement _player;
    [SerializeField]
    private Transform _checkpoint;

    public void LoadCheckpoint()
    {
        _player.LoadCheckpoint(_checkpoint);
    }

    public void UpdateCheckpoint(Transform newCheckPoint)
    {
        _checkpoint = newCheckPoint;
    }
}
