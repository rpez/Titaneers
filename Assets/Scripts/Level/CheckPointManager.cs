using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckPointManager : MonoBehaviour
{
    [SerializeField]
    private Transform _player;
    [SerializeField]
    private Transform _checkpoint;

    public void LoadCheckpoint()
    {
        _player.position = _checkpoint.position;
        _player.rotation = _checkpoint.rotation;
    }

    public void UpdateCheckpoint(Transform newCheckPoint)
    {
        _checkpoint = newCheckPoint;
    }
}
