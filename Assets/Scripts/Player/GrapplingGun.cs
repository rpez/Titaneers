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

using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class GrapplingGun : MonoBehaviour
{
    [Header("Assign in editor")]
    public GameObject HitpointPrefab;
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
    private LineRenderer _lineRenderer;
    private GameObject _grapplePoint;
    private SpringJoint _joint;
    private Missile _capturedMissile;

    // State booleans
    bool _isGrappling;

    // Other variables
    private int _currentCharges;
    private float _currentTime;

    void Awake()
    {
        _lineRenderer = GetComponent<LineRenderer>();
        _currentCharges = MaxCharges;
    }

    void Update()
    {
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
        }

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            LaunchGrapple();
        }
        else if (Mouse.current.leftButton.wasReleasedThisFrame)
        {
            StopGrapple();
        }
        if (Mouse.current.rightButton.wasPressedThisFrame)
        {
            if (_capturedMissile != null) GainProjectileControl();
        }
        else if (Mouse.current.rightButton.wasReleasedThisFrame)
        {
            if (_capturedMissile != null) RedirectProjectile();
        }
    }

    //Called after Update
    void LateUpdate()
    {
        DrawRope();
    }

    /// <summary>
    /// Call whenever we want to start a grapple
    /// </summary>
    void LaunchGrapple()
    {
        if (_currentCharges <= 0) return;
        RaycastHit hit;
        if (Physics.Raycast(PlayerCamera.position, PlayerCamera.forward, out hit, Range, GrappleLayer))
        {
            if (hit.transform.gameObject.tag == "Projectile")
            {
                _capturedMissile = hit.transform.gameObject.GetComponent<Missile>();
            }
            _grapplePoint = GameObject.Instantiate(HitpointPrefab, hit.point, Quaternion.identity);
            _grapplePoint.transform.parent = hit.transform;
            float distance = (_grapplePoint.transform.position - GunTip.transform.position).magnitude;
            StartCoroutine(Grapple(distance / GrappleSpeed));
        }
    }

    void ConnectGrapple()
    {
        _isGrappling = true;
        _joint = Player.gameObject.AddComponent<SpringJoint>();
        _joint.autoConfigureConnectedAnchor = false;
        _joint.connectedAnchor = _grapplePoint.transform.position;

        float distanceFromPoint = Vector3.Distance(Player.position, _grapplePoint.transform.position);

        //The distance grapple will try to keep from grapple point. 
        _joint.maxDistance = distanceFromPoint * MaxLengthMultiplier;
        _joint.minDistance = distanceFromPoint * MinLengthMultiplier;

        //Adjust these values to fit your game.
        _joint.spring = SpringForce;
        _joint.damper = Dampening;
        _joint.massScale = MassScale;

        _lineRenderer.positionCount = 2;
        currentGrapplePosition = GunTip.position;

        _currentCharges--;
    }

    void GainProjectileControl()
    {
        _capturedMissile.GainControl(ProjectileReceive.gameObject);
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

        _capturedMissile.Redirect(_capturedMissile.transform.position, transform.forward, target);
        _capturedMissile = null;
        StopGrapple();
    }

    /// <summary>
    /// Call whenever we want to stop a grapple
    /// </summary>
    void StopGrapple()
    {
        StopAllCoroutines();
        _lineRenderer.positionCount = 0;
        if (_grapplePoint != null) Destroy(_grapplePoint);
        _isGrappling = false;
        Destroy(_joint);
    }

    private Vector3 currentGrapplePosition;

    void DrawRope()
    {
        //If not grappling, don't draw rope
        if (!_joint) return;

        if (_grapplePoint == null)
        {
            StopGrapple();
            return;
        }
            
        currentGrapplePosition = Vector3.Lerp(currentGrapplePosition, _grapplePoint.transform.position, Time.deltaTime * 8f);

        _lineRenderer.SetPosition(0, GunTip.position);
        _lineRenderer.SetPosition(1, currentGrapplePosition);
    }

    public bool IsGrappling()
    {
        return _joint != null;
    }

    public Vector3 GetGrapplePoint()
    {
        return _grapplePoint.transform.position;
    }

    private IEnumerator Grapple(float delay)
    {
        yield return new WaitForSeconds(delay);
        ConnectGrapple();
    }
}