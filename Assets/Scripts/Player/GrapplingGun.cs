/*
    MIT License

    Copyright (c) 2020 DaniDevy

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

// Modified by rpez 2022

using System;
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class GrapplingGun : MonoBehaviour
{
    //Audio

    public string GrappleShoot = "Play_player_grapple_shoot";
    public string GrappleHit = "Play_player_grapple_hit";

    [Header("Assign in editor")]
    public GameObject HitpointPrefab;
    public GameObject RedirectEffect;
    public GrapplingRope Rope;
    public Transform GunTip, PlayerCamera, Player;
    public UI UIRef;

    [Header("Layers")]
    public LayerMask GrappleLayer;

    [Header("Grappling")]
    public float Range = 100f;
    public float indicatorRange = 2f;
    public float MaxLengthMultiplier = 0.1f;
    public float MinLengthMultiplier = 0.01f;
    public float SpringForce = 10f;
    public float Dampening = 10f;
    public float MassScale = 1f;
    public float GrappleSpeed = 100f;
    public float Cooldown = 3f;
    public int MaxCharges = 2;
    public float AimTimeWindow = 0.2f;

    // Other references
    private GameObject _grapplePoint;
    private SpringJoint _joint;
    private Missile _capturedMissile;
    
    private TimeManager _timeManager;
    private PlayerMovement _playerScript;

    // State booleans
    bool _isGrappling, _isLaunched, _controlling, _redirecting, _reeling, _ricochet;

    // Other variables
    private int _currentCharges;
    private float _currentTime;
    private float _stopTimeStamp;
    public float StopTimeStamp { get => _stopTimeStamp; }
    private Vector3 _defaultCameraPos;
    private Coroutine _launchRoutine;

    private PlayerControls _controls;
    private PlayerControls.GroundMovementActions _controlMapping;
    private Vector2Int[] _raycastOffsets = new Vector2Int[9];
    private (bool, RaycastHit, float)[] _raycastBuffer = new (bool, RaycastHit, float)[9];

    private void OnEnable()
    {
        _controls.Enable();
    }

    private void OnDestroy()
    {
        _controls.Disable();
    }

    void Awake()
    {
        _controls = new PlayerControls();
        _controlMapping = _controls.GroundMovement;
        _currentCharges = MaxCharges;
        _timeManager = GameObject.Find("TimeManager").GetComponent<TimeManager>();
        _defaultCameraPos = PlayerCamera.transform.localPosition;
        _controlMapping = _controls.GroundMovement;
        _playerScript = Player.GetComponent<PlayerMovement>();

        AkSoundEngine.RegisterGameObj(gameObject);

        // Hardcoded additional rays
        _raycastOffsets[0] = new Vector2Int(-32, -32);
        _raycastOffsets[1] = new Vector2Int(-32, 32);
        _raycastOffsets[2] = new Vector2Int(32, -32);
        _raycastOffsets[3] = new Vector2Int(32, 32);
        _raycastOffsets[4] = new Vector2Int(0, 32);
        _raycastOffsets[5] = new Vector2Int(0, -32);
        _raycastOffsets[6] = new Vector2Int(32, 0);
        _raycastOffsets[7] = new Vector2Int(-32, 0);
        _raycastOffsets[8] = new Vector2Int(0, 0);
    }

    void Update()
    {
        // UI update
        RaycastHit hit = new RaycastHit();
        //bool intersect = Physics.Raycast(PlayerCamera.position, PlayerCamera.forward, out hit, Range * indicatorRange);
        //if (!intersect) UIRef.ActiveIndicator(false);
        //else
        //{
        //    UIRef.ActiveIndicator(true);
        //    float distanceRatio = hit.distance / Range;
        //    UIRef.ChangeIndicator(distanceRatio / indicatorRange);
        //    bool withinRange = distanceRatio <= 1 ? true : false;
        //    if (((1 << hit.collider.gameObject.layer) & GrappleLayer.value) <= 0)
        //    {
        //        // not grapplable area
        //        UIRef.ChangeCrosshairIleagal(withinRange);
        //    }
        //    else UIRef.ResetCrosshairColor(withinRange);
        //}

        bool intersect = RaycastGrappleTarget(ref hit);
        if (intersect)
        {
            UIRef.ActiveIndicator(true);
        }
        else UIRef.ActiveIndicator(false);

        RaycastHit currentHit = new RaycastHit();
        bool rayHit = false;
        Vector2 center = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
        for (int i = 0; i < _raycastOffsets.Length; i++)
        {
            rayHit = Physics.Raycast(Camera.main.ScreenPointToRay(center + _raycastOffsets[i]), out currentHit, Range, GrappleLayer);
            if (rayHit)
            {
                _raycastBuffer[i] = (true, currentHit, Time.realtimeSinceStartup);
            }
            else
            {
                if (Time.realtimeSinceStartup - _raycastBuffer[i].Item3 > AimTimeWindow)
                {
                    _raycastBuffer[i] = (false, new RaycastHit(), 0f);
                }
            }
        }

        if (_currentCharges < MaxCharges)
        {
            _currentTime += Time.deltaTime;
            if (_currentTime >= Cooldown)
            {
                _currentCharges += 1;
                _currentTime = 0;
                UIRef.UpdateGrappleCharges(_currentCharges);
            }
        }

        _controlMapping.GrapplePull.performed += _ =>
        {
            if (_reeling)
            {
                _playerScript.StopPull();
                return;
            }
            else
            {
                if (_capturedMissile != null) GainProjectileControl();
                else if (_isGrappling)
                {
                    StartReelIn();
                }
            }
        };

        if (_isGrappling)
        {
            if (_grapplePoint == null)
            {
                StopGrapple();
            }
            else if (_joint != null) _joint.connectedAnchor = _grapplePoint.transform.position;

            if (_capturedMissile != null && !_capturedMissile.gameObject.GetComponent<ObjectPoolUnit>().Active)
            {
                ResetAfterRedirect();
            }
            else if (_redirecting && _capturedMissile != null)
            {
                float dot = Vector3.Dot(transform.forward, _capturedMissile.transform.position - transform.position);
                if (dot > 0f)
                {
                    RedirectProjectile();
                    _redirecting = false;
                }
            }

        }

        if (_controlMapping.GrapplePull.WasReleasedThisFrame())
        {
            if (_capturedMissile != null) _redirecting = true;
        }

        if (Mouse.current.rightButton.wasPressedThisFrame)
        {
            if (!_redirecting && !_controlling) LaunchGrapple();
        }
        else if (Mouse.current.rightButton.wasReleasedThisFrame)
        {
            if (!_redirecting && !_controlling) StopGrapple();
        }
    }

    private bool RaycastGrappleTarget(ref RaycastHit hit)
    {
        RaycastHit resultHit = new RaycastHit();
        bool rayHit = false;

        Vector2 center = new Vector2(Screen.width * 0.5f, Screen.height * 0.5f);
        for (int i = 0; i < _raycastOffsets.Length; i++)
        {
            RaycastHit currentHit = new RaycastHit();
            bool newHit = Physics.Raycast(Camera.main.ScreenPointToRay(center + _raycastOffsets[i]), out currentHit, Range, GrappleLayer);
            if (newHit)
            {
                resultHit = currentHit;
                rayHit = true;
            }
            else
            {
                if (_raycastBuffer[i].Item1)
                {
                    resultHit = _raycastBuffer[i].Item2;
                    rayHit = true;
                }
            }
        }

        hit = resultHit;
        return rayHit;
    }

    /// <summary>
    /// Call whenever we want to start a grapple
    /// </summary>
    private void LaunchGrapple()
    {
        if (_currentCharges <= 0) return;
        _isLaunched = true;

        RaycastHit hit = new RaycastHit();
        bool rayHit = RaycastGrappleTarget(ref hit);
        GameObject crosshairTarget = UIRef.GetCrosshairTarget();
        // Check whether raycast or crosshair hit is closer
        if (crosshairTarget != null)
        {
            if (rayHit)
            {
                if ((crosshairTarget.transform.position - transform.position).magnitude
                    < (hit.transform.position - transform.position).magnitude)
                {
                    Vector3 dir2 = (crosshairTarget.transform.position - transform.position).normalized;
                    rayHit = Physics.Raycast(PlayerCamera.position, dir2, out hit, Range, GrappleLayer);
                }
            }
            else
            {
                Vector3 dir = (crosshairTarget.transform.position - PlayerCamera.position).normalized;
                rayHit = Physics.Raycast(PlayerCamera.position, dir, out hit, Range, GrappleLayer);
            }
        }

        // If still no hit
        if (!rayHit)
        {
            _grapplePoint = GameObject.Instantiate(HitpointPrefab, transform.position + PlayerCamera.transform.forward * Range, Quaternion.identity);
            _grapplePoint.GetComponent<Renderer>().enabled = false;
            _ricochet = true;
        }
        else
        {
            _ricochet = false;
            if (hit.collider.gameObject.tag == "Projectile")
            {
                _capturedMissile = hit.collider.gameObject.GetComponent<Missile>();
            }

            _grapplePoint = Instantiate(HitpointPrefab, hit.point, Quaternion.identity);
            _grapplePoint.transform.parent = hit.collider.transform;
            AkSoundEngine.PostEvent(GrappleShoot, gameObject);
            float distance = (_grapplePoint.transform.position - GunTip.transform.position).magnitude;
            _launchRoutine = StartCoroutine(Delay(distance / GrappleSpeed, ConnectGrapple));
            Debug.Log(hit.collider.gameObject.tag);
            if (hit.collider.gameObject.tag == Tags.POWERUP_TAG)
            {
                var powerUp = hit.collider.gameObject.GetComponent<NewPowerUp>();
                StartCoroutine(OnGrapplePowerUp(powerUp));
            }
        }
    }

    private IEnumerator OnGrapplePowerUp(NewPowerUp powerup)
    {
        if (powerup == null) yield return null;
        float distance = (_grapplePoint.transform.position - GunTip.transform.position).magnitude;
        yield return new WaitForSeconds(distance / GrappleSpeed);
        if (powerup.IsCharged)
        {
            Rope.OnGrapplePowerUp();
            powerup.OnGrapple();
            _playerScript.OnPowerUpCollected(powerup.ChargeAmount);
        }
    }

    private void ConnectGrapple()
    {
        _isGrappling = true;
        _joint = Player.gameObject.AddComponent<SpringJoint>();
        _joint.autoConfigureConnectedAnchor = false;
        _joint.connectedAnchor = _grapplePoint.transform.position;
        AkSoundEngine.PostEvent(GrappleHit, _grapplePoint);

        float distanceFromPoint = Vector3.Distance(Player.position, _grapplePoint.transform.position);

        //The distance grapple will try to keep from grapple point. 
        _joint.maxDistance = distanceFromPoint * MaxLengthMultiplier;
        _joint.minDistance = distanceFromPoint * MinLengthMultiplier;

        //Adjust these values to fit your game.
        _joint.spring = SpringForce;
        _joint.damper = Dampening;
        _joint.massScale = MassScale;

        _currentCharges--;
        UIRef.UpdateGrappleCharges(_currentCharges);
    }

    private void GrappleRicochet()
    {

    }

    private void GainProjectileControl()
    {
        _capturedMissile.GainControl(gameObject);
        UIRef.ChangeCrosshairStyle(true);
        _controlling = true;
    }

    private void RedirectProjectile()
    {
        GameObject target = GameObject.Instantiate(HitpointPrefab, PlayerCamera.position + PlayerCamera.forward * 1000f, Quaternion.identity);

        RaycastHit hit;
        if (Physics.Raycast(PlayerCamera.position, PlayerCamera.forward, out hit))
        {
            target.transform.position = hit.point;
            target.transform.parent = hit.transform;
        }

        _capturedMissile.Redirect(_capturedMissile.transform.position, PlayerCamera.forward, target);

        StartCoroutine(Delay(1f, RedirectEffects));
    }

    private void StartReelIn()
    {
        if (_grapplePoint != null)
        {
            _playerScript.StartPullTowards(_grapplePoint, StopReelIn);
            Destroy(_joint);
            _reeling = true;
        }
    }

    private void StopReelIn()
    {
        _reeling = false;
        StopGrapple();
    }

    private void RedirectEffects()
    {
        _timeManager.FreezeFrame(0.4f);

        GameObject particles = GameObject.Instantiate(RedirectEffect, _capturedMissile.transform.position, Quaternion.identity);
        Destroy(particles, 5f);

        ResetAfterRedirect();
    }

    private void ResetAfterRedirect()
    {
        StopGrapple();
        UIRef.ChangeCrosshairStyle(false);
        _controlling = false;

        _capturedMissile = null;
    }

    /// <summary>
    /// Call whenever we want to stop a grapple
    /// </summary>
    private void StopGrapple()
    {
        if (_launchRoutine != null) StopCoroutine(_launchRoutine);
        if (_grapplePoint != null) Destroy(_grapplePoint);
        _isGrappling = false;
        _isLaunched = false;
        _stopTimeStamp = Time.time;
        Destroy(_joint);
    }

    public bool IsGrappling()
    {
        return _joint != null;
    }

    public bool IsLaunched()
    {
        return _isLaunched;
    }

    public bool IsRicochet()
    {
        return _ricochet;
    }

    public Transform GetGrapplePoint()
    {
        return _grapplePoint == null ? null : _grapplePoint.transform;
    }

    private IEnumerator Delay(float delay, Action callback)
    {
        yield return new WaitForSeconds(delay);
        callback.Invoke();
    }
}