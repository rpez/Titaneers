using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RootMotion.FinalIK;

public class TitanBehavior : MonoBehaviour
{
    public bool SwordExist { get; set; }
    public bool StopBehavior { get; set; }

    [SerializeField]
    private float _normalPlaySpeed;
    [SerializeField]
    private float _playSpeedMultiplier = 1f;
    [SerializeField]
    private Animator _animator;

    [SerializeField]
    private LookAtIK _ik;

    [Header("Hitboxs")]
    [SerializeField]
    private Transform _swordHitbox;
    [SerializeField]
    private Transform _lanternHitbox;

    [Header("VFX")]
    [SerializeField]
    private GameObject _lanternChargeVFX;
    [SerializeField]
    private Material _bossFresnel;
    [SerializeField]
    private float _maxFresnelIntensity = 1000f;
    [SerializeField]
    private SwordAttack _swordAttack;

    [Header("Function")]
    [SerializeField]
    private HurtBox[] _weaknessHurtBoxs;

    private void OnEnable()
    {
        EventManager.FreezeFrame += FreezeForSeconds;
    }

    private void OnDisable()
    {
        EventManager.FreezeFrame -= FreezeForSeconds;
    }

    private void FreezeForSeconds(float time)
    {
        StartCoroutine(Freeze(time));
    }

    private IEnumerator Freeze(float time)
    {
        _playSpeedMultiplier = 0.01f;

        yield return new WaitForSecondsRealtime(time);

        _playSpeedMultiplier = 1f;
    }

    private void Start()
    {
        SwordExist = true;
    }

    private void Update()
    {
        //IK
        _ik.solver.SetLookAtWeight(Mathf.Lerp(_ik.solver.IKPositionWeight, _animator.GetFloat("IKWeight"),0.5f*Time.deltaTime));

        //Play Speed
        _animator.speed = _playSpeedMultiplier * _normalPlaySpeed * _animator.GetFloat("PlaySpeed");

        //Hitbox
        _swordHitbox.transform.localScale = Vector3.one * _animator.GetFloat("SwordHitboxSize");
        _lanternHitbox.transform.localScale = Vector3.one * _animator.GetFloat("LanternHitboxSize");

        //VFX
        //Lantern charge
        _lanternChargeVFX.SetActive((_animator.GetFloat("LanternChargeVFX") > 0.99));
        _bossFresnel.SetFloat("_Intensity", _animator.GetFloat("BossFresnelIntensity") * _maxFresnelIntensity);
        //Sword
        if(_animator.GetFloat("SwordAttack") > 0.99)
        {
            StartCoroutine(_swordAttack.SwordWave());
        }

        //Function
        for(int i=0;i<_weaknessHurtBoxs.Length;i++)
        {
            _weaknessHurtBoxs[i].SetInstantDeath((_animator.GetFloat("LanternChargeVFX") > 0.99));
        }
    }
}
