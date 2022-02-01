using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostProcessingManager : MonoBehaviour
{
    public TimeSlowPPP m_timeSlowVolume;

    public void SetTimeSlowEffect(bool begin)
    {
        if (begin) m_timeSlowVolume.StartTransitionIn();
        else m_timeSlowVolume.StartTransitionOut();
    }

    public void SetTimeSlowEffectWeight(float value)
    {
        m_timeSlowVolume.SetWeight(value);
    }
}
