using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using DG.Tweening;
using Cinemachine;

public class DashAbility : AbilityBase
{
    [Header("Reference")]
    //[SerializeField] private Animator animator = default;
    //[SerializeField] private CinemachineVirtualCamera originalCam = default;
    [Header("Visuals")]
    //[SerializeField] private ParticleSystem dashParticle = default;
    [SerializeField] private Volume dashVolume = default;

    [Header("Params")]
    public float Distance = 20.0f;
    public override void Ability()
    {
        //animator.SetTrigger("Dash");
        //dashParticle.Play();

        Sequence dash = DOTween.Sequence()
        .Insert(0, transform.DOMove(transform.position + (_playerControl.DashDirection * Distance), .2f));
        //.AppendCallback(() => dashParticle.Stop())
        //.AppendCallback(() => damageable.isInvulnerable = false);


        DOVirtual.Float(0, 1, .1f, SetDashVolumeWeight)
            .OnComplete(() => DOVirtual.Float(1, 0, .5f, SetDashVolumeWeight));



        //DOVirtual.Float(40, 50, .1f, SetCameraFOV)
        //    .OnComplete(() => DOVirtual.Float(50, 40, .5f, SetCameraFOV));
    }

    void SetDashVolumeWeight(float weight)
    {
        dashVolume.weight = weight;
    }

    //void SetCameraFOV(float fov)
    //{
    //    originalCam.m_Lens.FieldOfView = fov;
    //}

}
