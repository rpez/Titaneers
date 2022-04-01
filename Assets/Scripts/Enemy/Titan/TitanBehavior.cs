using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using RootMotion.FinalIK;

public class TitanBehavior : MonoBehaviour
{
    public bool SwordExist { get; set; }

    [SerializeField]
    private float _normalPlaySpeed;
    [SerializeField]
    private Animator _animator;

    [SerializeField]
    private LookAtIK _ik;

    [Header("Hitboxs")]
    [SerializeField]
    private Transform _swordHitbox;
    [SerializeField]
    private Transform _lanternHitbox;

    private void Start()
    {
        SwordExist = true;
    }

    private void Update()
    {
        //IK
        _ik.solver.SetLookAtWeight(_animator.GetFloat("IKWeight"));

        //Play Speed
        _animator.speed = _normalPlaySpeed * _animator.GetFloat("PlaySpeed");

        //Hitbox
        if(_animator.GetCurrentAnimatorStateInfo(0).IsName("Sword"))
        {
            _swordHitbox.transform.localScale = Vector3.one* _animator.GetFloat("HitboxSize");
        }
        else if (_animator.GetCurrentAnimatorStateInfo(0).IsName("Lantern"))
        {
            _lanternHitbox.transform.localScale = Vector3.one * _animator.GetFloat("HitboxSize");
        }
        else
        {
            _swordHitbox.transform.localScale = Vector3.zero;
            _lanternHitbox.transform.localScale = Vector3.zero;
        }
    }
}
