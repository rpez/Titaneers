using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : MonoBehaviour
{
    //the sound controller can be put here.
    //public [Sound Controller Type] SoundContoller;

    public string LaserAim = "Play_titan_laser_aim";
    public string LaserShot = "Play_titan_laser_shot";

    public bool isAiming { get; private set; }

    [SerializeField]
    private GameObject _laserEye;

    [SerializeField]
    private Transform _shootPoint;

    [SerializeField]
    private LineRenderer _lineRenderer;
    [SerializeField]
    private float maxLength = 10000f;

    [SerializeField]
    private float _aimTime;
    public float AimTime { get => _aimTime; }
    [SerializeField]
    private float _aimRayWidth;

    [SerializeField]
    private float _interval = 0.5f;

    [SerializeField]
    private float _shootTime;
    [SerializeField]
    private Transform _hitbox;

    [SerializeField]
    private Transform _laserTrackTarget;

    private Transform _target;
    private BuildingPerformance _eyePerformance;
    private Collider _eyeCollider;
    private MeshRenderer _eyeRenderer;

    private void OnEnable()
    {
        AkSoundEngine.RegisterGameObj(gameObject);

        _target = GameObject.FindGameObjectWithTag("Player").transform;
        _eyePerformance = _laserEye.GetComponent<BuildingPerformance>();
        _eyeCollider = _laserEye.GetComponent<Collider>();
        _eyeRenderer= _laserEye.GetComponent<MeshRenderer>();
    }

    private  IEnumerator ShootLaser()
    {
        if (!_eyeRenderer.enabled) _eyeRenderer.enabled = true;
        _eyePerformance.Respawn();
        _eyeCollider.enabled = true;


        //Aim
        isAiming = true;
        //Sound: Laser start charging here
        

        float timer = _aimTime;
        while (timer > 0)
        {
            timer -= Time.deltaTime;
            _shootPoint.LookAt(_target);
            _lineRenderer.SetPosition(0, _shootPoint.position);

            _lineRenderer.SetPosition(1, _target.position);
            _lineRenderer.startWidth = _lineRenderer.endWidth = _aimRayWidth;

            yield return new WaitForFixedUpdate();

            AkSoundEngine.PostEvent(LaserAim, gameObject);
        }
        _lineRenderer.SetPosition(1, _shootPoint.position);
        _lineRenderer.startWidth = _lineRenderer.endWidth = 0f;
        
        isAiming = false;
        //Sound: Laser stop charging here

        yield return new WaitForSeconds(_interval);

        //Sound: Laser attack start here
        Vector3 shootTarget = _laserTrackTarget.position;

        timer = _shootTime;

        while (timer > 0)
        {
            timer -= Time.deltaTime;

            _shootPoint.LookAt(shootTarget);
            _hitbox.localScale = Vector3.one;
            yield return new WaitForFixedUpdate();

            AkSoundEngine.PostEvent(LaserShot, gameObject);
        }
        _hitbox.localScale = Vector3.zero;
        //Sound: Laser attack stop here

        //_laserEye.SetActive(false);
        _eyePerformance.Destroyed();
        _eyeCollider.enabled = false;
    }
}
