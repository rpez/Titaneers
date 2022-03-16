using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUp : MonoBehaviour
{

    private ObjectPoolUnit _poolUnit;
    private GameObject _playerObj;

    // Start is called before the first frame update
    void Start()
    {
        _poolUnit = GetComponent<ObjectPoolUnit>();
        _playerObj = GameObject.FindWithTag(Tags.PLAYER_TAG);
    }


    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == Tags.PLAYER_TAG)
        {
            _playerObj.GetComponent<PlayerMovement>().OnPowerUpCollected();
            gameObject.SetActive(false);    // pooled management
            _poolUnit.Deactivate();
        }
    }
}
