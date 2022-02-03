using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Rendering;

public class TimeSlowPPP : MonoBehaviour
{
    // References
    private PlayableDirector _director;
    private Volume _volume;

    public void StartTransitionIn()
    {
        _director.time = 0;
        _director.Play();
    }

    public void StartTransitionOut()
    {
        _director.time = 0;
        _director.Play();
    }

    public void SetWeight(float value)
    {
        if (value <= 1f && value >= 0f)
        {
            _volume.weight = value;
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        _director = GetComponent<PlayableDirector>();
        _volume = GetComponent<Volume>();
    }
}
