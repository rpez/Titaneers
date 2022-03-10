using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PowerUp : MonoBehaviour
{

    [SerializeField] private float _rotateSpeed = 1.0f;

    private ObjectPoolUnit _poolUnit;
    private GameObject _playerObj;

    // Start is called before the first frame update
    void Start()
    {
        _poolUnit = GetComponent<ObjectPoolUnit>();
        _playerObj = GameObject.FindWithTag(Tags.PLAYER_TAG);
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(new Vector3(0, _rotateSpeed * Time.deltaTime, 0), Space.World);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == Tags.PLAYER_TAG)
            _playerObj.GetComponent<PlayerMovement>().OnPowerUpCollected();
        gameObject.SetActive(false);    // pooled management
        _poolUnit.Deactivate();
    }
}
