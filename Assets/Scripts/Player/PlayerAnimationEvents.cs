using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAnimationEvents : MonoBehaviour
{
    public bool Debug_Enabled = false;
    public string LeftFootRun = "Play_player_fs_run_L";
    public string RightFootRun = "Play_player_fs_run_R";
    public string SpinAttack = "Play_player_spin_attack";
    public string FS = "Play_player_fs";

    public string Breathe = "Play_player_breathe";

    public string VocAttack = "Play_player_voc_attack";
    public string VocJump = "Play_player_voc_jump";
    public string VocTakeHit = "Play_player_voc_take_hit";
    public string VocTakeHitSoft = "Play_player_voc_take_hit_soft";
    public string VocDeath = "Play_player_voc_death";
    public string VocGrapplePull = "Play_player_voc_grapple_pull";

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

    void Play_player_fs()
    {
        if (Debug_Enabled) { Debug.Log("Player FS triggered"); }
        AkSoundEngine.PostEvent(FS, gameObject);
    }

    void Play_player_spin_attack()
    {
        if (Debug_Enabled) { Debug.Log("Player spin attack triggered"); }
        AkSoundEngine.PostEvent(SpinAttack, gameObject);
    }

    void Play_player_breathe()
    {
        if (Debug_Enabled) { Debug.Log("Player breathe"); }
        AkSoundEngine.PostEvent(Breathe, gameObject);

    }

    void Play_player_voc_attack()
    {
        if (Debug_Enabled) { Debug.Log("Player voc attack"); }
        AkSoundEngine.PostEvent(VocAttack, gameObject);

    }

    void Play_player_voc_jump()
    {
        if (Debug_Enabled) { Debug.Log("Player voc jump"); }
        AkSoundEngine.PostEvent(VocJump, gameObject);

    }

    void Play_player_voc_grapple_pull()
    {
        if (Debug_Enabled) { Debug.Log("Player voc grapple pull"); }
        AkSoundEngine.PostEvent(VocGrapplePull, gameObject);

    }

    public void Play_player_voc_take_hit()
    {
        if (Debug_Enabled) { Debug.Log("Player voc take hit"); }
        AkSoundEngine.PostEvent(VocTakeHit, gameObject);

    }

    public void Play_player_voc_take_hit_soft()
    {
        if (Debug_Enabled) { Debug.Log("Player voc take hit soft"); }
        AkSoundEngine.PostEvent(VocTakeHitSoft, gameObject);

    }

    public void Play_player_voc_death()
    {
        if (Debug_Enabled) { Debug.Log("Player voc death"); }
        AkSoundEngine.PostEvent(VocDeath, gameObject);

    }

 


}
