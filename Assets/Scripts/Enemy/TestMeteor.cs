using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMeteor : MonoBehaviour
{
    public GameObject Vfx;
    public Transform StartPoint;
    public Transform EndPoint;
    // Start is called before the first frame update
    void Start()
    {
        var starPos = StartPoint.position;
        GameObject objVfx = Instantiate(Vfx, starPos, Quaternion.identity) as GameObject;
        var endPos = EndPoint.position;
        RotateTo(objVfx, endPos);
    }


    void RotateTo(GameObject obj, Vector3 dest)
    {
        var direction = dest - obj.transform.position;
        var rotation = Quaternion.LookRotation(direction);
        obj.transform.localRotation = Quaternion.Lerp(obj.transform.rotation, rotation, 1);
    }
    // Update is called once per frame
    void Update()
    {
        
    }
}
