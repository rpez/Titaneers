using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    public bool Debug_Enabled = false;
    public string LeftFootRun = "Play_player_fs_run_L";
    public string RightFootRun = "Play_player_fs_run_R";
    // Start is called before the first frame update
    void Start()
    {
        
        AkSoundEngine.RegisterGameObj(gameObject);
        
    }

    void Play_player_fs_run_L()
    {
        if (Debug_Enabled) { Debug.Log("Left foot triggered!"); }
        AkSoundEngine.PostEvent(LeftFootRun, gameObject);

    }

    void Play_player_fs_run_R()
    {
        if (Debug_Enabled) { Debug.Log("Right foot triggered!"); }
        AkSoundEngine.PostEvent(RightFootRun, gameObject);
    }


}