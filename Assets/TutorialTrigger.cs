using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialTrigger : MonoBehaviour
{
    public int tutorialIdx;
    public int cutSceneIdx;

    private void OnTriggerEnter(Collider other)
    {
        GameObject obj = GameObject.Find("TutorialLevel");
        TutorialController ctrl = obj.GetComponent<TutorialController>();
        if (cutSceneIdx != 0)
        {
            ctrl.OnEnterCutScene(cutSceneIdx);
        }
        else ctrl.OnCollisionBox(tutorialIdx);
        gameObject.SetActive(false);
    }
}
