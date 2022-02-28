using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TitanAnimationEvents : MonoBehaviour
{
    public string TitanFs = "Play_titan_fs";
    public string TitanTrampleFoot = "Play_titan_trample_foot";
    public string TitanTrampleVoc = "Play_titan_trample_voc";

    // Start is called before the first frame update
    void Start()
    {
        AkSoundEngine.RegisterGameObj(gameObject);

    }

    void Play_titan_fs()
    {
        AkSoundEngine.PostEvent(TitanFs, gameObject);
    }

    void Play_titan_trample_foot()
    {
        AkSoundEngine.PostEvent(TitanTrampleFoot, gameObject);
    }

    void Play_titan_trample_voc()
    {
        AkSoundEngine.PostEvent(TitanTrampleVoc, gameObject);
    }

    
}
