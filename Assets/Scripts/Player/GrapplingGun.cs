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
    public LayerMask whatIsGrappleable;

    [Header("Assign in Editor")]
    public GameObject hitpointPrefab;
    public Transform gunTip, playerCam, player;

    [Header("Grapple Parameters")]
    public float range = 100f;
    public float maxLengthMultiplier = 0.1f;
    public float minLengthMultiplier = 0.01f;
    public float springForce = 10f;
    public float dampening = 10f;
    public float massScale = 1f;
    public float grappleSpeed = 1f;
    public int maxCharges = 2;
    public float cooldown = 3f;

    private int currentCharges;
    private float currentTime;
    private LineRenderer lr;
    private GameObject grapplePoint;
    
    private SpringJoint joint;

    bool isGrappling;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        currentCharges = maxCharges;
    }

    void Update()
    {
        if (currentCharges < maxCharges)
        {
            currentTime += Time.deltaTime;
            if (currentTime >= cooldown)
            {
                currentCharges += 1;
                currentTime = 0;
            }
        }

        if (isGrappling)
        {
            joint.connectedAnchor = grapplePoint.transform.position;
        }

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            LaunchGrapple();
        }
        else if (Mouse.current.leftButton.wasReleasedThisFrame)
        {
            StopGrapple();
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
        if (currentCharges <= 0) return;
        RaycastHit hit;
        if (Physics.Raycast(playerCam.position, playerCam.forward, out hit, range, whatIsGrappleable))
        {
            grapplePoint = GameObject.Instantiate(hitpointPrefab, hit.point, Quaternion.identity);
            grapplePoint.transform.parent = hit.transform;
            float distance = (grapplePoint.transform.position - gunTip.transform.position).magnitude;
            StartCoroutine(Grapple(distance / grappleSpeed));
        }
    }

    void ConnectGrapple()
    {
        isGrappling = true;
        joint = player.gameObject.AddComponent<SpringJoint>();
        joint.autoConfigureConnectedAnchor = false;
        joint.connectedAnchor = grapplePoint.transform.position;

        float distanceFromPoint = Vector3.Distance(player.position, grapplePoint.transform.position);

        //The distance grapple will try to keep from grapple point. 
        joint.maxDistance = distanceFromPoint * maxLengthMultiplier;
        joint.minDistance = distanceFromPoint * minLengthMultiplier;

        //Adjust these values to fit your game.
        joint.spring = springForce;
        joint.damper = dampening;
        joint.massScale = massScale;

        lr.positionCount = 2;
        currentGrapplePosition = gunTip.position;

        currentCharges--;
    }

    /// <summary>
    /// Call whenever we want to stop a grapple
    /// </summary>
    void StopGrapple()
    {
        StopAllCoroutines();
        lr.positionCount = 0;
        Destroy(grapplePoint);
        isGrappling = false;
        Destroy(joint);
    }

    private Vector3 currentGrapplePosition;

    void DrawRope()
    {
        //If not grappling, don't draw rope
        if (!joint) return;

        currentGrapplePosition = Vector3.Lerp(currentGrapplePosition, grapplePoint.transform.position, Time.deltaTime * 8f);

        lr.SetPosition(0, gunTip.position);
        lr.SetPosition(1, currentGrapplePosition);
    }

    public bool IsGrappling()
    {
        return joint != null;
    }

    public Vector3 GetGrapplePoint()
    {
        return grapplePoint.transform.position;
    }

    private IEnumerator Grapple(float delay)
    {
        yield return new WaitForSeconds(delay);
        ConnectGrapple();
    }
}