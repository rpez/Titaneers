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
    public Transform GunTip, PlayerCamera, Player;
    public Transform ProjectileReceive, ProjectileSend;

    [Header("Layers")]
    public LayerMask GrappleLayer;

    [Header("Grappling")]
    public float Range = 100f;
    public float MaxLengthMultiplier = 0.1f;
    public float MinLengthMultiplier = 0.01f;
    public float SpringForce = 10f;
    public float Dampening = 10f;
    public float MassScale = 1f;
    public float GrappleSpeed = 100f;
    public float Cooldown = 3f;
    public int MaxCharges = 2;

    // Other references
    private GameObject _grapplePoint;
    private SpringJoint _joint;
    private Missile _capturedMissile;
    private UI _ui;
    private TimeManager _timeManager;

    // State booleans
    bool _isGrappling, _isLaunched, _controlling, _redirecting;

    // Other variables
    private int _currentCharges;
    private float _currentTime;
    private Vector3 _defaultCameraPos;
    private Coroutine _launchRoutine;

    void Awake()
    {
        _currentCharges = MaxCharges;
        _ui = GameObject.Find("Canvas").GetComponent<UI>();
        _timeManager = GameObject.Find("TimeManager").GetComponent<TimeManager>();
        _defaultCameraPos = PlayerCamera.transform.localPosition;

        AkSoundEngine.RegisterGameObj(gameObject);
    }

    void Update()
    {
        RaycastHit hit;
        if (Physics.Raycast(PlayerCamera.position, PlayerCamera.forward, out hit, Range, GrappleLayer)
            || _ui.GetCrosshairTarget() != null
            && (_ui.GetCrosshairTarget().transform.position - PlayerCamera.position).magnitude < Range)
        {
            _ui.ChangeCrosshairColor(Color.red);
        }
        else _ui.ResetCrosshairColor();

        if (_currentCharges < MaxCharges)
        {
            _currentTime += Time.deltaTime;
            if (_currentTime >= Cooldown)
            {
                _currentCharges += 1;
                _currentTime = 0;
            }
        }



        if (_isGrappling)
        {
            if (_grapplePoint == null)
            {
                StopGrapple();
            }
            else _joint.connectedAnchor = _grapplePoint.transform.position;

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

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            if (!_redirecting && !_controlling) LaunchGrapple();
        }
        else if (Mouse.current.leftButton.wasReleasedThisFrame)
        {
            if (!_redirecting && !_controlling) StopGrapple();
        }
        if (Mouse.current.rightButton.wasPressedThisFrame)
        {
            if (_capturedMissile != null) GainProjectileControl();
        }
        else if (Mouse.current.rightButton.wasReleasedThisFrame)
        {
            if (_capturedMissile != null) _redirecting = true;
        }
    }

    /// <summary>
    /// Call whenever we want to start a grapple
    /// </summary>
    void LaunchGrapple()
    {
        if (_currentCharges <= 0) return;
        _isLaunched = true;

        RaycastHit hit;
        bool rayHit = Physics.Raycast(PlayerCamera.position, PlayerCamera.forward, out hit, Range, GrappleLayer);
        GameObject crosshairTarget = _ui.GetCrosshairTarget();

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
        if (!rayHit) return;

        if (hit.transform.gameObject.tag == "Projectile")
        {
            _capturedMissile = hit.transform.gameObject.GetComponent<Missile>();
        }
        _grapplePoint = GameObject.Instantiate(HitpointPrefab, hit.point, Quaternion.identity);
        _grapplePoint.transform.parent = hit.collider.transform;
        AkSoundEngine.PostEvent(GrappleShoot, gameObject);
        float distance = (_grapplePoint.transform.position - GunTip.transform.position).magnitude;
        _launchRoutine = StartCoroutine(Delay(distance / GrappleSpeed, ConnectGrapple));

        //Debug.DrawRay(PlayerCamera.position, PlayerCamera.forward * Range, Color.green, 10f);
    }

    void ConnectGrapple()
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
    }

    void GainProjectileControl()
    {
        _capturedMissile.GainControl(ProjectileReceive.gameObject);
        //PlayerCamera.transform.localPosition = PlayerCamera.transform.localPosition + Vector3.back * 5f;
        _ui.ChangeCrosshairStyle(true);
        _controlling = true;
        //_joint.spring = SpringForce * 10f;
        //_joint.damper = Dampening * 10f;
        //_joint.massScale = MassScale;
        //_joint.maxDistance = 1f;
        //_joint.minDistance = 0.1f;
    }

    void RedirectProjectile()
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

    private void RedirectEffects()
    {
        _timeManager.FreezeFrame(0.4f);
        //PlayerCamera.transform.localPosition = _defaultCameraPos;

        GameObject particles = GameObject.Instantiate(RedirectEffect, _capturedMissile.transform.position, Quaternion.identity);
        Destroy(particles, 5f);

        ResetAfterRedirect();
    }

    private void ResetAfterRedirect()
    {
        StopGrapple();
        _ui.ChangeCrosshairStyle(false);
        _controlling = false;

        _capturedMissile = null;
    }

    /// <summary>
    /// Call whenever we want to stop a grapple
    /// </summary>
    void StopGrapple()
    {
        if (_launchRoutine != null) StopCoroutine(_launchRoutine);
        //_lineRenderer.positionCount = 0;
        if (_grapplePoint != null) Destroy(_grapplePoint);
        _isGrappling = false;
        _isLaunched = false;
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