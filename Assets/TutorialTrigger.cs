using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialTrigger : MonoBehaviour
{
    public int tutorialIdx;
    private void OnTriggerEnter(Collider other)
    {
        GameObject obj = GameObject.Find("TutorialLevel");
        TutorialController ctrl = obj.GetComponent<TutorialController>();
        ctrl.OnCollisionBox(tutorialIdx);
        gameObject.SetActive(false);
    }
}
