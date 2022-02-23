using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HitBoxManager : MonoBehaviour
{
    [SerializeField]
    private HitBox[] _hitBoxes;

    private Dictionary<string, HitBox> _hitBoxesDic;

    private void Start()
    {
        _hitBoxesDic = new Dictionary<string, HitBox>();
        for(int i=0;i<_hitBoxes.Length;i++)
        {
            _hitBoxesDic.Add(_hitBoxes[i].name, _hitBoxes[i]);
        }
    }

    public void ActivateHitBox(string name)
    {
        _hitBoxesDic[name].gameObject.SetActive(true);
    }

    public void DeactivateHitBox(string name)
    {
        _hitBoxesDic[name].gameObject.SetActive(false);
    }
}
