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

// Some stupid rigidbody based movement by Dani
// Modified by rpez 2022

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{

    //Assingables
    public Transform playerCam;
    public Transform orientation;

    //Other
    private Rigidbody rb;

    //Rotation and look
    private float xRotation;
    //private float sensitivity = 50f;
    //private float sensMultiplier = 1f;

    //Movement
    public float moveSpeed = 4500;
    public float maxSpeed = 20;
    public bool grounded;
    public LayerMask whatIsGround;
    public float mouseSensitivity = 100;

    public float counterMovement = 0.175f;
    private float threshold = 0.1f;
    public float maxSlopeAngle = 35f;
    public float slideLandingBoost = 10f;

    //Crouch & Slide
    private float crouchHeight = 1f;
    private Vector3 crouchCameraOffset = new Vector3(0f, -1f, 0f);
    private Vector3 crouchCameraPosition;
    private float playerHeight;
    private Vector3 defaultCameraPostion;
    private CapsuleCollider collider;
    public float slideForce = 400;
    public float slideCounterMovement = 0.2f;

    // Dash
    public float dashStrength = 20f;
    public float dashTime = 0.3f;
    public Vector3 dashDirection;
    public float dashSpeedBoost = 2f;
    public int maxDashCharges = 2;
    public float dashCooldown = 3f;
    private int currentDashCharges;
    private float currentCdTime;

    //Jumpings
    private bool readyToJump = true;
    private float jumpCooldown = 0.25f;
    public float jumpForce = 550f;

    //Input
    float x, y;
    bool jumping, sprinting, crouching, dashing;

    //Sliding
    private Vector3 normalVector = Vector3.up;
    private Vector3 wallNormalVector;

    PlayerControls controls;
    PlayerControls.GroundMovementActions map;
    public Vector2 horizontalInput;

    public TimeManager m_timeManager;
    private bool m_slowTime;

    private List<GameObject> m_floorContactsLastFrame = new List<GameObject>();

    private void OnEnable()
    {
        controls.Enable();
    }

    private void OnDestroy()
    {
        controls.Disable();
    }

    void Awake()
    {
        controls = new PlayerControls();
        map = controls.GroundMovement;
        rb = GetComponent<Rigidbody>();
    }

    void Start()
    {
        collider = GetComponent<CapsuleCollider>();
        playerHeight = collider.height;
        defaultCameraPostion = playerCam.localPosition;
        crouchCameraPosition = defaultCameraPostion - crouchCameraOffset;
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        m_timeManager = GameObject.Find("TimeManager").GetComponent<TimeManager>();
        currentDashCharges = maxDashCharges;
    }


    private void FixedUpdate()
    {
        Movement();
    }

    private void Update()
    {
        MyInput();
        Look();
    }

    /// <summary>
    /// Find user input. Should put this in its own class but im lazy
    /// </summary>
    private void MyInput()
    {
        map.Move.performed += context => horizontalInput = context.ReadValue<Vector2>();
        x = horizontalInput.x;
        y = horizontalInput.y;
        map.Jump.performed += _ => jumping = true;
        map.Dash.performed += _ =>
        {
            if (!dashing) StartCoroutine(Dash());
        };
        map.TimeSlow.performed += _ =>
        {
            m_slowTime = !m_slowTime;
            m_timeManager.ToggleTimeScale(0.05f, m_slowTime);
        };
        map.Crouch.performed += _ => crouching = true;

        //Crouching
        if (map.Crouch.WasPressedThisFrame())
            StartCrouch();
        if (map.Crouch.WasReleasedThisFrame())
            StopCrouch();
    }

    private void StartCrouch()
    {
        collider.height = crouchHeight;
        playerCam.localPosition = crouchCameraPosition;
        //transform.position = new Vector3(transform.position.x, transform.position.y - 0.5f, transform.position.z);
        if (rb.velocity.magnitude > 0.5f)
        {
            if (grounded)
            {
                rb.AddForce(orientation.transform.forward * slideForce);
            }
        }
    }

    private void StopCrouch()
    {
        collider.height = playerHeight;
        playerCam.localPosition = defaultCameraPostion;
        crouching = false;
        transform.position = new Vector3(transform.position.x, transform.position.y + 0.5f, transform.position.z);
    }

    private void Movement()
    {

        //Extra gravity
        rb.AddForce(Vector3.down * Time.deltaTime * 10);

        //Find actual velocity relative to where player is looking
        Vector2 mag = FindVelRelativeToLook();
        float xMag = mag.x, yMag = mag.y;

        //Counteract sliding and sloppy movement
        CounterMovement(x, y, mag);

        //If holding jump && ready to jump, then jump
        if (readyToJump && jumping) Jump();

        //Set max speed
        float maxSpeed = this.maxSpeed;

        if (dashing)
        {
            transform.Translate(dashDirection * dashStrength * Time.unscaledDeltaTime);
        }
        else
        {
            //If speed is larger than maxspeed, cancel out the input so you don't go over max speed
            if (x > 0 && xMag > maxSpeed) x = 0;
            if (x < 0 && xMag < -maxSpeed) x = 0;
            if (y > 0 && yMag > maxSpeed) y = 0;
            if (y < 0 && yMag < -maxSpeed) y = 0;

            //Some multipliers
            float multiplier = 1f, multiplierV = 1f;

            // Movement in air
            if (!grounded)
            {
                multiplier = 0.5f;
                multiplierV = 0.5f;
            }

            // Movement while sliding
            if (grounded && crouching) multiplierV = 0f;

            //Apply forces to move player
            rb.AddForce(orientation.transform.forward * y * moveSpeed * Time.deltaTime * multiplier * multiplierV);
            rb.AddForce(orientation.transform.right * x * moveSpeed * Time.deltaTime * multiplier);
        }

        //If sliding down a ramp, add force down so player stays grounded and also builds speed
        if (crouching && grounded && readyToJump)
        {
            rb.AddForce(Vector3.down * Time.deltaTime * 3000);
            return;
        }

        if (currentDashCharges < maxDashCharges)
        {
            currentCdTime += Time.deltaTime;
            if (currentCdTime >= dashCooldown)
            {
                currentDashCharges += 1;
                currentCdTime = 0;
            }
        }
    }

    private void Jump()
    {
        if (grounded && readyToJump)
        {
            readyToJump = false;

            //Add jump forces
            rb.AddForce(Vector2.up * jumpForce * 1.5f);
            rb.AddForce(normalVector * jumpForce * 0.5f);

            //If jumping while falling, reset y velocity.
            Vector3 vel = rb.velocity;
            if (rb.velocity.y < 0.5f)
                rb.velocity = new Vector3(vel.x, 0, vel.z);
            else if (rb.velocity.y > 0)
                rb.velocity = new Vector3(vel.x, vel.y / 2, vel.z);

            Invoke(nameof(ResetJump), jumpCooldown);
        }
    }

    private IEnumerator Dash()
    {
        if (currentDashCharges > 0)
        {
            dashDirection = orientation.transform.forward * y + orientation.transform.right * x;
            if (dashDirection.magnitude < 0.01f) yield break; // Workaround fix because sometimes the input is 0 for whatever reason

            dashing = true;
            currentDashCharges--;

            Vector3 vel = rb.velocity;
            rb.velocity = Vector3.zero;
            rb.useGravity = false;
            dashDirection.Normalize();
            float angle = Vector3.Angle(dashDirection, vel);

            yield return new WaitForSeconds(dashTime * Time.unscaledDeltaTime);

            dashing = false;
            // Keep momentum if dash is towards relatively same direction
            rb.velocity = angle <= 50f ? vel * dashSpeedBoost : Vector3.zero;
            rb.useGravity = true;
        }
    }

    private void ResetJump()
    {
        readyToJump = true;
    }


    private float desiredX;
    private void Look()
    {
        float mouseX = 0, mouseY = 0;

        if (Mouse.current != null)
        {
            var delta = Mouse.current.delta.ReadValue();// / 15.0f;
            mouseX += delta.x;
            mouseY += delta.y;
        }

        mouseX *= mouseSensitivity * Time.unscaledDeltaTime;
        mouseY *= mouseSensitivity * Time.unscaledDeltaTime;

        //Find current look rotation
        Vector3 rot = playerCam.transform.localRotation.eulerAngles;
        desiredX = rot.y + mouseX;

        //Rotate, and also make sure we dont over- or under-rotate.
        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        //Perform the rotations
        playerCam.transform.localRotation = Quaternion.Euler(xRotation, desiredX, 0);
        orientation.transform.localRotation = Quaternion.Euler(0, desiredX, 0);
    }

    private void CounterMovement(float x, float y, Vector2 mag)
    {
        if (!grounded || jumping || dashing) return;

        //Slow down sliding
        if (crouching)
        {
            rb.AddForce(moveSpeed * Time.deltaTime * -rb.velocity.normalized * slideCounterMovement);
            return;
        }

        //Counter movement
        if (Math.Abs(mag.x) > threshold && Math.Abs(x) < 0.05f
            || (mag.x < -threshold && x > 0) || (mag.x > threshold && x < 0))
        {
            rb.AddForce(moveSpeed * orientation.transform.right * Time.deltaTime * -mag.x * counterMovement);
        }
        if (Math.Abs(mag.y) > threshold && Math.Abs(y) < 0.05f
            || (mag.y < -threshold && y > 0) || (mag.y > threshold && y < 0))
        {
            rb.AddForce(moveSpeed * orientation.transform.forward * Time.deltaTime * -mag.y * counterMovement);
        }

        //Limit diagonal running. This will also cause a full stop if sliding fast and un-crouching, so not optimal.
        if (Mathf.Sqrt((Mathf.Pow(rb.velocity.x, 2) + Mathf.Pow(rb.velocity.z, 2))) > maxSpeed)
        {
            float fallspeed = rb.velocity.y;
            Vector3 n = rb.velocity.normalized * maxSpeed;
            rb.velocity = new Vector3(n.x, fallspeed, n.z);
        }
    }

    /// <summary>
    /// Find the velocity relative to where the player is looking
    /// Useful for vectors calculations regarding movement and limiting movement
    /// </summary>
    /// <returns></returns>
    public Vector2 FindVelRelativeToLook()
    {
        float lookAngle = orientation.transform.eulerAngles.y;
        float moveAngle = Mathf.Atan2(rb.velocity.x, rb.velocity.z) * Mathf.Rad2Deg;

        float u = Mathf.DeltaAngle(lookAngle, moveAngle);
        float v = 90 - u;

        float magnitude = new Vector2(rb.velocity.x, rb.velocity.z).magnitude;
        float yMag = magnitude * Mathf.Cos(u * Mathf.Deg2Rad);
        float xMag = magnitude * Mathf.Cos(v * Mathf.Deg2Rad);

        return new Vector2(xMag, yMag);
    }

    private bool IsFloor(Vector3 v)
    {
        float angle = Vector3.Angle(Vector3.up, v);
        return angle < maxSlopeAngle;
    }

    private bool cancellingGrounded;

    /// <summary>
    /// Handle ground detection
    /// </summary>
    private void OnCollisionStay(Collision other)
    {
        //Make sure we are only checking for walkable layers
        int layer = other.gameObject.layer;
        if (whatIsGround != (whatIsGround | (1 << layer))) return;

        m_floorContactsLastFrame.Clear();

        //Iterate through every collision in a physics update
        for (int i = 0; i < other.contactCount; i++)
        {
            Vector3 normal = other.contacts[i].normal;
            //FLOOR
            if (IsFloor(normal))
            {
                m_floorContactsLastFrame.Add(other.gameObject);
                if (!grounded)
                {
                    grounded = true;
                    if (crouching)
                    {
                        // If landing on a floor, boost slide
                        rb.AddForce(moveSpeed * orientation.transform.forward * Time.deltaTime * slideLandingBoost);
                    }
                }
                if (jumping) jumping = false;
                cancellingGrounded = false;
                normalVector = normal;
                CancelInvoke(nameof(StopGrounded));
            }
        }

        //Invoke ground/wall cancel, since we can't check normals with CollisionExit
        //float delay = 3f;
        //if (!cancellingGrounded)
        //{
        //    cancellingGrounded = true;
        //    Invoke(nameof(StopGrounded), Time.deltaTime * delay);
        //}
    }

    private void OnCollisionExit(Collision collision)
    {
        if (m_floorContactsLastFrame.Contains(collision.gameObject))
        {
            m_floorContactsLastFrame.Remove(collision.gameObject);
            if (m_floorContactsLastFrame.Count <= 0)
            {
                StopGrounded();
            }
        }
    }

    private void StopGrounded()
    {
        grounded = false;
    }

}