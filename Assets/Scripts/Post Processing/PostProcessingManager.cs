using UnityEngine;

public class PostProcessingManager : MonoBehaviour
{
    [Header("Assign in editor")]
    public TimeSlowPPP TimeSlowVolume;

    public void SetTimeSlowEffect(bool begin)
    {
        if (begin) TimeSlowVolume.StartTransitionIn();
        else TimeSlowVolume.StartTransitionOut();
    }

    public void SetTimeSlowEffectWeight(float value)
    {
        TimeSlowVolume.SetWeight(value);
    }
}
