using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMissile : MonoBehaviour, BeAttack
{
    [SerializeField] private float _maxHp;
    [SerializeField] private Transform _spawnPoint;
    [SerializeField] private GameObject _missilePrefab;

    private float _hp;
    private float _lastShootTs;
    private UI _ui;

    // Start is called before the first frame update
    void Start()
    {
        _hp = _maxHp;
        _ui = GameObject.Find("Canvas").GetComponent<UI>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.time - _lastShootTs >= 4.5f)
        {
            Attack();
            _lastShootTs = Time.time;
        }
    }

    public void Attack()
    {
        GameObject player = GameObject.FindGameObjectWithTag(Tags.PLAYER_TAG);
        Rigidbody rb = player.GetComponent<Rigidbody>();
        GameObject missileObj = Instantiate(_missilePrefab, _spawnPoint.position, Quaternion.identity);
        _ui.AddThreat(missileObj);
        Missile missile = missileObj.GetComponent<Missile>();
        missile.SetTarget(rb);
        if (_spawnPoint.gameObject.GetComponent<Collider>() != null)
            Physics.IgnoreCollision(missile.GetComponent<Collider>(), _spawnPoint.gameObject.GetComponent<Collider>());
    }
    public void BeAttack(float damage)
    {
        _hp -= damage;
        if (_hp <= 0)
        {
            if (this.gameObject != null)
            {
                Destroy(this);
            }
        }
    }
}
