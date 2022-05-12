using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using DG.Tweening;
using Cinemachine;
using System;

public class AttackAbility : AbilityBase
{
    [Header("Reference")]
    [SerializeField] private Animator _animator = default;
    [SerializeField] private GameObject _sword;
    [SerializeField] private GameObject _slashParent;
    [SerializeField] private GameObject _swordTip;
    [SerializeField] private HitBox _swordHitbox;
    [SerializeField] private CameraBehaviour _camera;
    //[SerializeField] private CinemachineVirtualCamera originalCam = default;

    [Header("Visuals")]
    [SerializeField] private GameObject _swordVFX;
    [SerializeField] private GameObject _impactVFX;
    [SerializeField] private Volume _attackVolume = default;

    [Header("Params")]
    public float AttackWindUp = 0.3f;
    public float AttackTime = 0.5f;
    public float MaxDamage = 10.0f;
    public float HitBoxScaler = 0.005f;
    public float ImpactVFXScaler = 0.01f;
    public float RebounceScalar = 2.0f;
    public float MinRebounceSpeed = 20.0f;
    public float RebounceUpRatio = 0.2f;
    public float BigRebounceDuration = 2.0f;
    public float RebounceDuration = 0.5f;
    public float BigRebounceSpeed = 100.0f;
    public float SlowTime = 0.5f;
    public float SlowScale = 0.1f;
    public float TrailDelay = 0.0f;

    private bool _impactFlag = false;

    public override void Ability()
    {
        _impactFlag = false;
        Sequence dash = DOTween.Sequence()
        .AppendCallback(OnStartAttack)
        .AppendInterval(AttackWindUp)
        .AppendCallback(() =>
        {
            // active hit box
            _swordHitbox.gameObject.SetActive(true);
            _swordHitbox.Initialize(MaxDamage * _playerControl.CurrentVelocity.magnitude / _playerControl.MaxAirSpeed, AttackImpact);
            _sword.transform.localScale *= Mathf.Max(1f, _playerControl.CurrentVelocity.magnitude * HitBoxScaler);
        })
        .AppendInterval(TrailDelay)
        .AppendCallback(() =>
        {
            GameObject swordTrail = Instantiate(_swordVFX, _slashParent.transform);
            ScaleVFX(swordTrail, _playerControl.CurrentVelocity.magnitude);
            Destroy(swordTrail, 5f);
        })
        .AppendInterval(AttackTime)
        .AppendCallback(OnEndAttack);

        //DOVirtual.Float(0, 1, .1f, SetDashVolumeWeight)
        //    .OnComplete(() => DOVirtual.Float(1, 0, .5f, SetDashVolumeWeight));

        //DOVirtual.Float(40, 50, .1f, SetCameraFOV)
        //    .OnComplete(() => DOVirtual.Float(50, 40, .5f, SetCameraFOV));
    }

    private void OnEndAttack()
    {
        _playerControl.IsAttacking = false;
        _swordHitbox.gameObject.SetActive(false);
        _camera.OnAttackEnd();
        _sword.transform.localScale = Vector3.one;
    }

    private void OnStartAttack()
    {
        _animator.SetInteger("state", 3);
        _playerControl.IsAttacking = true;
    }


    private void AttackImpact(GameObject hitObject)
    {
        Vector3 hitDir = (hitObject.transform.position - transform.position).normalized;
        RaycastHit hit;
        bool raycast = Physics.Raycast(transform.position, hitDir, out hit, 100f);
        if (hitObject.tag == Tags.WEAKNESS_TAG)
        {
            BigRebounce(hit);
            OnHitWeakness(hitObject);
        }
        
        // only generate VFX once
        if (_impactFlag)
            return;

        _impactFlag = true;
        GameObject hitEffect;
        if (raycast)
        {
            hitEffect = Instantiate(_impactVFX, hit.point, Quaternion.identity);
            hitEffect.transform.rotation = Quaternion.FromToRotation(Vector3.up, hit.normal) * hitEffect.transform.rotation;
        }
        else
        {
            hitEffect = Instantiate(_impactVFX, _swordTip.transform.position, Quaternion.identity);
        }
        //hitEffect = GameObject.Instantiate(ImpactVFX, SwordTip.transform.position + hitDir * 3f, Quaternion.identity);
        Destroy(hitEffect, 5f);
        ScaleVFX(hitEffect, GetHitVelocity().magnitude);

        _playerControl.StopPull();

        // Rebounce
        if (!_playerControl.IsRebouncing)
        {
            Rebounce(hit);
        }
    }

    private Vector3 GetHitVelocity()
    {
        Vector3 hitVelocity;
        if (_playerControl.CurrentVelocity.magnitude <= 15f) hitVelocity = _playerControl.VelocityBuffer;
        else hitVelocity = _playerControl.CurrentVelocity;
        return hitVelocity;
    }
    private void Rebounce(RaycastHit hit)
    {
        if (_playerControl.IsRebouncing) return;
        
        Vector3 hitVelocity = GetHitVelocity();
        Rigidbody playerRigidbody = GetComponent<Rigidbody>();
        float rebounceVelocity = Mathf.Max(hitVelocity.magnitude * RebounceScalar, MinRebounceSpeed);
        Vector3 rebounceDirection = hit.normal + Vector3.up * RebounceUpRatio;

        Debug.DrawLine(hit.point, hit.point + rebounceDirection * 100, Color.red, 2, false);
        playerRigidbody.velocity = rebounceDirection.normalized * rebounceVelocity;
        //Debug.LogFormat("Rebounce velocity {0}", playerRigidbody.velocity);

        float rebounceDuration = RebounceDuration;
        CapsuleCollider collider = GetComponent<CapsuleCollider>();
        collider.enabled = false;
        _playerControl.SetMoveInputActive(false);
        _playerControl.IsRebouncing = true;
        DOTween.Sequence()
           .AppendInterval(rebounceDuration)
           .AppendCallback(() => _playerControl.SetMoveInputActive(true))
           .AppendCallback(() => _playerControl.IsRebouncing = false)
           .AppendCallback(() => collider.enabled = true);
    }

    private void BigRebounce(RaycastHit hit)
    {
        // if not in rebounce status
        Rebounce(hit);
        // change rebounce direction and velocity
        Vector3 rebounceDirection = new Vector3(hit.normal.x, 1f, hit.normal.z);
        float rebounceVelocity = BigRebounceSpeed;
        Rigidbody playerRigidbody = GetComponent<Rigidbody>();
        Debug.DrawLine(hit.point, hit.point + rebounceDirection * 100, Color.green, 20, false);
        playerRigidbody.velocity = rebounceDirection.normalized * rebounceVelocity;
        //Debug.LogFormat("Big Rebounce velocity {0}", playerRigidbody.velocity);

    }

    private void OnHitWeakness(GameObject hitObject)
    {
        TimeManager timeManager = GameObject.Find("TimeManager").GetComponent<TimeManager>();
        EventManager.OnFreezeFrame(SlowTime);
        _camera.OnAttack();
        _camera.NoiseImpulse(30f, 6f, 0.7f);
        
        Time.timeScale = SlowScale;
        DOTween.Sequence()
           .InsertCallback(SlowTime * SlowScale, () => Time.timeScale = 1f);
    }

    //void SetVolumeWeight(float weight)
    //{
    //    Volume.weight = weight;
    //}

    private void ScaleVFX(GameObject vfx, float scale)
    {
        for (int i = 0; i < vfx.transform.childCount; i++)
        {
            vfx.transform.GetChild(i).transform.localScale *= Mathf.Max(1f, scale * ImpactVFXScaler);
        }
    }

    //void SetCameraFOV(float fov)
    //{
    //    originalCam.m_Lens.FieldOfView = fov;
    //}

}
