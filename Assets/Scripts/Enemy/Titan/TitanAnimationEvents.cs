using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitanAnimationEvents : MonoBehaviour
{
    public bool Debug_Enabled = false;
    public string TitanFsL = "Play_titan_fs_L";
    public string TitanFsR = "Play_titan_fs_R";
    public string TitanVocGeneric = "Play_titan_voc_generic";
    public string TitanSwordCharge = "Play_titan_sword_attack_charge";
    public string TitanSwordHit = "Play_titan_sword_attack_hit";
    //public string TitanTrampleFoot = "Play_titan_trample_foot";
    //public string TitanTrampleVoc = "Play_titan_trample_voc";
    public GameObject Head;
    public GameObject LeftFoot;
    public GameObject RightFoot;
    public GameObject Chest;
    public GameObject Sword;

    // Start is called before the first frame update
    void Start()
    {
        AkSoundEngine.RegisterGameObj(Head);
        AkSoundEngine.RegisterGameObj(LeftFoot);
        AkSoundEngine.RegisterGameObj(RightFoot);
        AkSoundEngine.RegisterGameObj(Chest);
        AkSoundEngine.RegisterGameObj(Sword);

    }

    void Play_titan_fs_L()
    {
        if (Debug_Enabled) { Debug.Log("Titan Left Foot Triggered"); }
        AkSoundEngine.PostEvent(TitanFsL,LeftFoot);
    }

    void Play_titan_fs_R()
    {
        if (Debug_Enabled) { Debug.Log("Titan Right Foot Triggered"); }
        AkSoundEngine.PostEvent(TitanFsR, RightFoot);
    }

    void Play_titan_voc_generic()
    {
        if (Debug_Enabled) { Debug.Log("Titan Generic Voc Triggered"); }
        AkSoundEngine.PostEvent(TitanVocGeneric, Head);
    }

    void Play_titan_sword_attack_charge()
    {
        AkSoundEngine.PostEvent(TitanSwordCharge, Head);

    }

    void Play_titan_sword_attack_hit()
    {
        AkSoundEngine.PostEvent(TitanSwordHit, Sword);
    }

   /* void Play_titan_trample_foot()
    {
        AkSoundEngine.PostEvent(TitanTrampleFoot, gameObject);
    }
   */

    /*void Play_titan_trample_voc()
    {
        AkSoundEngine.PostEvent(TitanTrampleVoc, Head);
    }
    */


}
