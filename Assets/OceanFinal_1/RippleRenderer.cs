using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;


[ExecuteAlways]
public class RippleRenderer : MonoBehaviour {


  public  Material reactionDiffusionMaterial;
  public Renderer[] renders;

  public OrthographicDepthRenderer depthRenderer;
  public Texture depthTexture;


  public Vector2 resolution;
  public int flip;

  [SerializeField]
  float texelMultiplier = 0.75f;

  [SerializeField]
  int passesPerFrame = 5;


  private RenderTexture t1;
  private RenderTexture t2;

  public bool RunInEditMode;
  public Transform rippler;

  public float rippleMax;
  public float rippleFalloff;
  public float rippleMultiplier;


  private Collider collider;

  public void OnEnable(){

    InitRenderTextures();
    depthTexture = depthRenderer.texture;        

     #if UNITY_EDITOR 
        EditorApplication.update += Always;
    #endif

    collider = GetComponent<Collider>();
  }



  void Always(){    
    #if UNITY_EDITOR 
    if( RunInEditMode ){ EditorApplication.QueuePlayerLoopUpdate();}
    #endif
  }

  public  void OnDisable() {
    RenderTexture.DestroyImmediate(t1);
    RenderTexture.DestroyImmediate(t2);

    #if UNITY_EDITOR 
        EditorApplication.update -= Always;
    #endif
  }
  



  public void Update() {



    //  print("hi");
    
    //RenderTexture tempTex = RenderTexture.GetTemporary((int)resolution.x, (int)resolution.y);

    reactionDiffusionMaterial.SetVector("_Resolution", resolution);
    reactionDiffusionMaterial.SetVector("_TexelSize", new Vector4(1 / resolution.x, 1 / resolution.y, 0f, 0f) * texelMultiplier);
    reactionDiffusionMaterial.SetMatrix("_Transform", transform.localToWorldMatrix);

   /* if( data.inputEvents.hitTag == "Pond" && data.inputEvents.Down ==1 ){
      reactionDiffusionMaterial.SetVector("_HitUV",data.inputEvents.hit.textureCoord );
      reactionDiffusionMaterial.SetInt("_Down", 1 );
    }else{
      reactionDiffusionMaterial.SetInt("_Down", 0 );
    }*/



    RaycastHit hit;
        Ray ray = new Ray( rippler.position , Vector3.down);//Camera.main.ScreenPointToRay(Input.mousePosition);
        
        
        if (collider.Raycast(ray, out hit , 10000)) {

      
          //print(hit.textureCoord);
          reactionDiffusionMaterial.SetVector("_HitUV", hit.textureCoord );

         
          reactionDiffusionMaterial.SetFloat("_Down", Mathf.Clamp( rippleMultiplier/Mathf.Pow(hit.distance,rippleFalloff),0,rippleMax) );


        }else{
              reactionDiffusionMaterial.SetInt("_Down", 0 );
        }

    //reactionDiffusionMaterial.SetVector("_HitUV", new Vector2( (Mathf.Sin(Time.time)) ,(-Mathf.Cos(Time.time))  ) * .1f + Vector2.one * .5f );
    //reactionDiffusionMaterial.SetInt("_Down", 1 );


    for( int i = 0; i < passesPerFrame; i++ ){
      Flip();
    }


  }


  public void Flip(){

    flip ++;
    flip %= 2;

    if( depthTexture != null ){
        reactionDiffusionMaterial.SetTexture("_DepthTexture", depthTexture);
    }


    if( flip == 0){
      reactionDiffusionMaterial.SetTexture("_RDLast", t1);
      Graphics.Blit(t1, t2, reactionDiffusionMaterial);

      for( var i = 0; i < renders.Length; i++ ){
        renders[i].sharedMaterial.SetTexture("_RDMain", t2);
      }
    }else{
      reactionDiffusionMaterial.SetTexture("_RDLast", t2);
      Graphics.Blit(t2, t1, reactionDiffusionMaterial);   
      for( var i = 0; i < renders.Length; i++ ){
        renders[i].sharedMaterial.SetTexture("_RDMain", t1);
      }
    }

  }

  public void InitRenderTextures() {
    t1 = new RenderTexture((int)resolution.x, (int)resolution.y, 0, RenderTextureFormat.ARGBFloat);
    t2 = new RenderTexture((int)resolution.x, (int)resolution.y, 0, RenderTextureFormat.ARGBFloat);

    //t1.filterMode= FilterMode.Point;
    //t2.filterMode= FilterMode.Point;
  }
}

