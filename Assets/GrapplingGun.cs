using UnityEngine;
using UnityEngine.InputSystem;

public class GrapplingGun : MonoBehaviour
{
    public GameObject hitpointPrefab;
    private LineRenderer lr;
    private GameObject grapplePoint;
    public LayerMask whatIsGrappleable;
    public Transform gunTip, camera, player;
    private float maxDistance = 1000f;
    private SpringJoint joint;

    bool isGrappling;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
    }

    void Update()
    {
        if (isGrappling)
        {
            joint.connectedAnchor = grapplePoint.transform.position;
        }

        if (Mouse.current.leftButton.wasPressedThisFrame)
        {
            StartGrapple();
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
    void StartGrapple()
    {
        RaycastHit hit;
        if (Physics.Raycast(camera.position, camera.forward, out hit, maxDistance, whatIsGrappleable))
        {
            isGrappling = true;
            grapplePoint = GameObject.Instantiate(hitpointPrefab, hit.point, Quaternion.identity);
            grapplePoint.transform.parent = hit.transform;
            
            joint = player.gameObject.AddComponent<SpringJoint>();
            joint.autoConfigureConnectedAnchor = false;
            joint.connectedAnchor = grapplePoint.transform.position;

            float distanceFromPoint = Vector3.Distance(player.position, grapplePoint.transform.position);

            //The distance grapple will try to keep from grapple point. 
            joint.maxDistance = distanceFromPoint * 0.1f;
            joint.minDistance = distanceFromPoint * 0.01f;

            //Adjust these values to fit your game.
            joint.spring = 10f;
            joint.damper = 10f;
            joint.massScale = 1f;

            lr.positionCount = 2;
            currentGrapplePosition = gunTip.position;
        }
    }


    /// <summary>
    /// Call whenever we want to stop a grapple
    /// </summary>
    void StopGrapple()
    {
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
}