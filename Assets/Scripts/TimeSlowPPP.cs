using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering;
using UnityEngine.Timeline;

public class TimeSlowPPP : MonoBehaviour
{
    public TimelineAsset m_slowTimelineIn;
    public TimelineAsset m_slowTimelineOut;

    private PlayableDirector m_director;

    private Volume m_volume;

    public void StartTransitionIn()
    {
        m_director.playableAsset = m_slowTimelineIn;
        m_director.time = 0;
        m_director.Play();
    }

    public void StartTransitionOut()
    {
        m_director.playableAsset = m_slowTimelineOut;
        m_director.time = 0;
        m_director.Play();
    }

    public void SetWeight(float value)
    {
        if (value <= 1f && value >= 0f)
        {
            m_volume.weight = value;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        m_director = GetComponent<PlayableDirector>();
        m_volume = GetComponent<Volume>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
