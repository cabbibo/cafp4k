using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class OrthographicDepthRenderer : MonoBehaviour
{

  public int renderSize;
  public float camSize;
  public RenderTexture texture;
  
  public string layerToRender;


  public Renderer debugRenderer;
  public Camera cam;

  public Shader replacementShader;


  public bool saveOut;
  public string textureSaveName;


  


  private RenderTextureDescriptor textureDescriptor;

  public void OnEnable(){

    Set();
  }

  public void Update(){
    //Set();
  }



  public void Set(){
   
    textureDescriptor = new RenderTextureDescriptor( renderSize,renderSize,RenderTextureFormat.Depth,24);
    texture = new RenderTexture( textureDescriptor );

 
    cam.targetTexture = texture;
    cam.orthographicSize = camSize; 
    cam.depthTextureMode = DepthTextureMode.DepthNormals;
    
    if( replacementShader != null ){
      cam.SetReplacementShader(replacementShader,null);
    }

    cam.SetTargetBuffers( texture.colorBuffer , texture.depthBuffer );
    cam.Render();


    /*if( debugRenderer ){
        debugRenderer.sharedMaterial.SetTexture("_MainTex", texture );
        debugRenderer.transform.localScale = Vector3.one * cam.orthographicSize * 2;
    }*/

    this.enabled = false;

 
  //  if( saveOut ){ SaveTexture( texture ); }

  }


    public RenderTexture rt;   

    public Material blitMat;//= blit; 
  // Use this for initialization
  public void SaveTexture (RenderTexture texture) {

    print("save");


    RenderTexture rt = new RenderTexture( renderSize, renderSize,0,RenderTextureFormat.ARGB32);// texture = RenderTexture.GetTemporary( textureDescriptor );

    Texture2D tex = new Texture2D(renderSize, renderSize, TextureFormat.ARGB32, false);
    
    blitMat.SetTexture( "_DepthTexture", texture);


    Graphics.Blit(texture,rt, blitMat);

    Texture2D t = toTexture2D(rt);
    byte[] bytes = t.EncodeToPNG();
    System.IO.File.WriteAllBytes(Application.dataPath + "/" + textureSaveName + ".png", bytes);
    DestroyImmediate(t);
      
  }
  Texture2D toTexture2D(RenderTexture rTex)
  {
      Texture2D tex = new Texture2D(renderSize, renderSize, TextureFormat.ARGB32, false);
      RenderTexture.active = rTex;
      tex.ReadPixels(new Rect(0, 0, rTex.width, rTex.height), 0, 0);
      tex.Apply();
      
      return tex;
  }



}

