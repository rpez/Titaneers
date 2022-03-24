using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeteorSpawner : MonoBehaviour
{
    public GameObject Vfx;
    public Transform StartPoint;
    public Transform EndPoint;
    public GameObject Titan;
    // Start is called before the first frame update
    void Start()
    {
        Titan.SetActive(false);
        var starPos = StartPoint.position;
        GameObject objVfx = Instantiate(Vfx, starPos, Quaternion.identity);
        MeteorMove meteor = objVfx.GetComponent<MeteorMove>();
        meteor.OnExplode.AddListener(OnMeteorExplode);
        var endPos = EndPoint.position;
        RotateTo(objVfx, endPos);
    }

    void OnMeteorExplode()
    {
        Debug.Log("OnMeteorExplode");
        Titan.SetActive(true);
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
