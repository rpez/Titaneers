using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitanSensor : MonoBehaviour
{
    public Transform _target;
    
    public Vector3 HorizontalDistance
    {
        get
        {

            Vector3 d = _target.position - transform.position;
            d.y = 0;
            return d;
        }
    }

    public Vector3 VerticalDistance
    {
        get
        {

            Vector3 d = _target.position - transform.position;
            d.x = d.z = 0;
            return d;
        }
    }

    public float DirectionAngle
    {
        get
        {
            Vector3 d = _target.position - transform.position;
            d.y = 0;
            Vector3 f = transform.forward;
            f.y = 0;
            float angle = Vector3.Angle(f, d);
            return angle;
        }
    }
}
