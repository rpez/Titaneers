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

    public override void Ability()
    {
        Sequence dash = DOTween.Sequence()
        .AppendInterval(AttackWindUp)
        .AppendCallback(OnStartAttack)
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
        GameObject swordTrail = Instantiate(_swordVFX, _sword.transform);
        ScaleVFX(swordTrail, _playerControl.CurrentVelocity.magnitude);
        _swordHitbox.gameObject.SetActive(true);
        _swordHitbox.Initialize(MaxDamage * _playerControl.CurrentVelocity.magnitude / _playerControl.MaxAirSpeed, AttackImpact);
        _sword.transform.localScale *= Mathf.Max(1f, _playerControl.CurrentVelocity.magnitude * HitBoxScaler);
    }


    private void AttackImpact(GameObject hitObject)
    {
        Vector3 hitDir = (hitObject.transform.position - transform.position).normalized;
        GameObject hitEffect;
        RaycastHit hit;
        if (Physics.Raycast(transform.position, hitDir, out hit, 100f))
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

        Vector3 hitVelocity = Vector3.zero;
        if (_playerControl.CurrentVelocity.magnitude <= 10f) hitVelocity = _playerControl.VelocityBuffer;
        else hitVelocity = _playerControl.CurrentVelocity;

        ScaleVFX(hitEffect, hitVelocity.magnitude);

        _playerControl.StopPull();

        // Rebounce
        Rigidbody playerRigidbody = GetComponent<Rigidbody>();
        playerRigidbody.velocity = Vector3.up * hitVelocity.magnitude;

        EventManager.OnFreezeFrame(0.5f);

        _camera.OnAttack();
        _camera.NoiseImpulse(30f, 6f, 0.7f);

        CapsuleCollider collider = GetComponent<CapsuleCollider>();
        DOTween.Sequence().AppendCallback(() => collider.enabled = false)
            .AppendInterval(1.0f)
            .AppendCallback(() => collider.enabled = true);
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
