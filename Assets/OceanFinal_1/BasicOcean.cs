using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;


[ExecuteAlways]
public class BasicOcean : MonoBehaviour
{


    public int oceanMeshResolution;
    public float oceanMeshSize;

    public OrthographicDepthRenderer depthRenderer;

private MaterialPropertyBlock materialPropertyBlock;
private Renderer renderer;
    // Start is called before the first frame update
    void OnEnable()
    {
      

        materialPropertyBlock = new MaterialPropertyBlock();
        renderer = GetComponent<Renderer>();
        renderer.GetPropertyBlock(materialPropertyBlock);
        MakeOceanMesh();
        
    }

    void Update(){

        materialPropertyBlock.SetTexture( "_DepthMap" ,depthRenderer.texture);
        materialPropertyBlock.SetVector("_DepthCamPos", depthRenderer.cam.transform.position);
        materialPropertyBlock.SetFloat("_DepthCamSize", depthRenderer.cam.orthographicSize);
        materialPropertyBlock.SetFloat("_DepthCamNear", depthRenderer.cam.nearClipPlane);
        materialPropertyBlock.SetFloat("_DepthCamFar", depthRenderer.cam.farClipPlane);


         renderer.SetPropertyBlock(materialPropertyBlock);

    }



    public void MakeOceanMesh(){

        Vector3[] positions = new Vector3[ oceanMeshResolution * oceanMeshResolution ];
        Vector3[] normals = new Vector3[ oceanMeshResolution * oceanMeshResolution ];
        Vector4[] tangents = new Vector4[ oceanMeshResolution * oceanMeshResolution ];
        Vector2[] uvs = new Vector2[ oceanMeshResolution * oceanMeshResolution ];
        int[] tris = new int[ (oceanMeshResolution-1) *(oceanMeshResolution-1) * 3 * 2 ];


        Mesh mesh = new Mesh();

        mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
        int index = 0;
    

        for( var i = 0; i< oceanMeshResolution; i++ ){
            for( var j = 0; j < oceanMeshResolution; j++ ){

                float x = (float)i / (float)oceanMeshResolution;
                float y = (float)j / (float)oceanMeshResolution;

                positions[i * oceanMeshResolution + j] = new Vector3(x-.5f,0,y-.5f) * oceanMeshSize;
                normals[i * oceanMeshResolution + j] = new Vector3(0,1,0);
                tangents[i * oceanMeshResolution + j] = new Vector4(1,0,0,0);
                uvs[i * oceanMeshResolution + j] = new Vector2(x,y);


                // do the IDS
                if( j < oceanMeshResolution-1 && i < oceanMeshResolution-1){

                    tris[index++] =     i * oceanMeshResolution + j;
                    tris[index++] =     i * oceanMeshResolution + j+1;
                    tris[index++] = (i+1) * oceanMeshResolution + j+1;
                    tris[index++] =     i * oceanMeshResolution + j;
                    tris[index++] = (i+1) * oceanMeshResolution + j+1;
                    tris[index++] = (i+1) * oceanMeshResolution + j;

                }

            }
        }
        
        mesh.vertices = positions;
        mesh.tangents = tangents;
        mesh.normals = normals;
        mesh.uv = uvs;
        mesh.triangles = tris;
        //mesh.indexFormat = IndexFormat.UInt32;

        GetComponent<MeshFilter>().mesh = mesh;


    }


    GameObject[] FindGameObjectsWithLayer ( int layer) {
        var goArray = UnityEngine.Object.FindObjectsOfType<GameObject>() ;
        var goList = new List<GameObject>();
        for (var i = 0; i < goArray.Length; i++) {
            if (goArray[i].layer == layer) {
                goList.Add(goArray[i]);
            }
        }
        if (goList.Count == 0) {
            return null;
        }
        return goList.ToArray();
    }


   


}
