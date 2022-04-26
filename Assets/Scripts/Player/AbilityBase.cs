using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public abstract class AbilityBase : MonoBehaviour
{
    public class MyFloatEvent : UnityEvent<float> { }
    public MyFloatEvent OnAbilityUse = new MyFloatEvent();
    [Header("Ability Info")]
    public string Title;
    public Sprite Icon;
    public float CooldownTime = 1;
    private bool CanUse = true;
    protected PlayerMovement _playerControl;

    public void Start()
    {
        _playerControl = GetComponent<PlayerMovement>();
    }

    public void TriggerAbility()
    {
        if (CanUse)
        {
            OnAbilityUse.Invoke(CooldownTime);
            Ability();
            StartCooldown();
        }

    }
    public abstract void Ability();
    void StartCooldown()
    {
        StartCoroutine(Cooldown());
        IEnumerator Cooldown()
        {
            CanUse = false;
            yield return new WaitForSeconds(CooldownTime);
            CanUse = true;
        }
    }
}
