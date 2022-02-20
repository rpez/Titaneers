using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//Make damage by a ray
public class HitScan : MonoBehaviour
{
    [SerializeField]
    private float _damage;
    [SerializeField]
    private float _maxDistance = 1000f;
    [SerializeField]
    private LayerMask _layers;

    public bool EmitHitRay(Vector3 origin, Vector3 direction, out RaycastHit hitInfo)
    {
        RaycastHit hit;
        if(Physics.Raycast(origin,direction,out hit, _maxDistance, _layers))
        {
            hitInfo = hit;
            HurtBox hurtBox;
            if (hurtBox = hit.collider.GetComponent<HurtBox>())
            {
                DealDamage(hurtBox);
                return true;
            }
        }
        hitInfo = hit;
        return false;
    }

    private void DealDamage(HurtBox hurtBox)
    {
        hurtBox.ReceiveDamage(_damage);
    }
}
