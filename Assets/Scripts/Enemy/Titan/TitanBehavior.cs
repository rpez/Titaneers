using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitanBehavior : MonoBehaviour
{
    [SerializeField]
    private AnimationCurve _lanternLightRangeCurve;
    [SerializeField]
    private GameObject _lanternLight;

    public IEnumerator LanternAttack()
    {
        float length = _lanternLightRangeCurve.keys[_lanternLightRangeCurve.length - 1].time;
        float timer = 0;
        while(timer<length)
        {
            _lanternLight.transform.localScale = Vector3.one * _lanternLightRangeCurve.Evaluate(timer);
            timer += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
    }
}
