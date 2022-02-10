using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMissile : MonoBehaviour
{

    [SerializeField] private Transform _spawnPoint;
    [SerializeField] private GameObject _missilePrefab;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.realtimeSinceStartup % 5f >= 4.5f)
        {
            Attack();
        }
    }

    public void Attack()
    {
        StartCoroutine(ShootMissile());
    }
    //Animation event
    private IEnumerator ShootMissile()
    {
        GameObject player = GameObject.FindGameObjectWithTag(Tags.PLAYER_TAG);
        Rigidbody rb = player.GetComponent<Rigidbody>();
        for (int i = 0; i < 1; ++i)
        {
            GameObject missileObj = Instantiate(_missilePrefab, _spawnPoint.position, Quaternion.identity);
            Missile missile = missileObj.GetComponent<Missile>();
            missile.SetTarget(rb);
            Physics.IgnoreCollision(missile.GetComponent<Collider>(), _spawnPoint.gameObject.GetComponent<Collider>());
            yield return new WaitForSeconds(.5f);
        }
    }
}
