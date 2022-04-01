using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CutArmSystem : MonoBehaviour
{
    private Mesh _fallArmMesh;

    public void CutArm(GameObject arm)
    {
        GameObject fallArm = new GameObject();
        fallArm.transform.position = arm.transform.position;
        fallArm.transform.rotation = arm.transform.rotation;

        SkinnedMeshRenderer armMesh=arm.GetComponent<SkinnedMeshRenderer>();
        arm.SetActive(false);

        _fallArmMesh = new Mesh();
        armMesh.BakeMesh(_fallArmMesh);

        MeshFilter armMeshFilter = fallArm.AddComponent<MeshFilter>();
        armMeshFilter.mesh = _fallArmMesh;

        MeshRenderer armMeshRender = fallArm.AddComponent<MeshRenderer>();
        armMeshRender.material = armMesh.material;

        Rigidbody armRB = fallArm.AddComponent<Rigidbody>();
        armRB.useGravity = true;

        MeshCollider armMC = fallArm.AddComponent<MeshCollider>();
        armMC.sharedMesh = _fallArmMesh;
    }

    private void OnDestroy()
    {
        DestroyImmediate(_fallArmMesh);
        Debug.Log("falling arm mesh destroied");
    }
}
