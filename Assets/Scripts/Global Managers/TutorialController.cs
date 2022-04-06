using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Video;

public class TutorialController : MonoBehaviour
{
    public RenderTexture targetTex;
    public VideoPlayer VideoPlayerRef;
    public Canvas TutorialCanvas;
    public Text TextRef;
    public string[] paths;
    public string[] hintMsg;


    private void Start()
    {
    }


    public void OnCollisionBox(int idx)
    {
        PlayTutorial(idx);
    }

    // Start is called before the first frame update
    void PlayTutorial(int idx)
    {
        TutorialCanvas.gameObject.SetActive(true);
        Time.timeScale = 0;
        // VideoPlayer automatically targets the camera backplane when it is added
        // to a camera object, no need to change videoPlayer.targetCamera.

        // Play on awake defaults to true. Set it to false to avoid the url set
        // below to auto-start playback since we're in Start().
        VideoPlayerRef.playOnAwake = false;

        // By default, VideoPlayers added to a camera will use the far plane.
        // Let's target the near plane instead.
        VideoPlayerRef.renderMode = UnityEngine.Video.VideoRenderMode.RenderTexture;
        VideoPlayerRef.targetTexture = targetTex;

        // Set the video to play. URL supports local absolute or relative paths.
        // Here, using absolute.
        VideoPlayerRef.url = System.IO.Path.Combine(Application.dataPath, paths[idx]);

        // Restart from beginning when done.
        VideoPlayerRef.isLooping = false;

        // Each time we reach the end, we slow down the playback by a factor of 10.
        VideoPlayerRef.loopPointReached += EndReached;
        TextRef.text = hintMsg[idx];

        // Start playback. This means the VideoPlayer may have to prepare (reserve
        // resources, pre-load a few frames, etc.). To better control the delays
        // associated with this preparation one can use videoPlayer.Prepare() along with
        // its prepareCompleted event.
        VideoPlayerRef.Play();
    }

    void EndReached(VideoPlayer vp)
    {
        TutorialCanvas.gameObject.SetActive(false);
        Time.timeScale = 1;
    }
}
