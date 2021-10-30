
Shader "Debug/RopeParticleDebug" {
    Properties {

    _Color ("Color", Color) = (1,1,1,1)
    _Size ("Size", float) = .01
    }


  SubShader{
    Cull Off
    Pass{

      CGPROGRAM
      
      #pragma target 4.5

      #pragma vertex vert
      #pragma fragment frag

      #include "UnityCG.cginc"

struct Rope{
  float3 pos;
  float3 oPos;
  float3 tPos;
  float3 nor;
  float3 tang;
  float2 uv;
  float3 debug;
};


    



      uniform float _Size;
      uniform float3 _Color;

      
      StructuredBuffer<Rope> _RopeBuffer;


      //A simple input struct for our pixel shader step containing a position.
      struct varyings {
          float4 pos      : SV_POSITION;
          float3 nor      : TEXCOORD0;
          float3 worldPos : TEXCOORD1;
          float3 eye      : TEXCOORD2;
          float2 debug    : TEXCOORD3;
          float2 uv       : TEXCOORD4;
          float2 uv2       : TEXCOORD6;
          float id        : TEXCOORD5;
          float type :TEXCOORD7;
      };

//Our vertex function simply fetches a point from the buffer corresponding to the vertex index
//which we transform with the view-projection matrix before passing to the pixel program.
varyings vert (uint id : SV_VertexID){

  varyings o;

  int base = id / 6;

  int whichRopePoint = base /4;
  int whichType = base % 4;
  int alternate = id %6;

      Rope v = _RopeBuffer[whichRopePoint];
      float3 extra = float3(0,0,0);
float3 l;
float3 u;


if( whichType == 0 ){

  l = UNITY_MATRIX_V[0].xyz * 2;
  u = UNITY_MATRIX_V[1].xyz * 2;
    
}else if( whichType == 1 ){

  l = v.nor* 10;
  u = normalize(cross(UNITY_MATRIX_V[2],l));

  v.pos -= l  * _Size;

}else if( whichType == 2 ){

  l = v.tang* 10;
  u = normalize(cross(UNITY_MATRIX_V[2],l));

  
  v.pos -= l * _Size;
  
}else{

  l = normalize(cross(v.tang,v.nor)) * 10;
  u = normalize(cross(UNITY_MATRIX_V[2],l));
  
  v.pos -= l * _Size;
  
}


    float2 uv = float2(0,0);

    if( alternate == 0 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 1 ){ extra =  l - u; uv = float2(1,0); }
    if( alternate == 2 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 3 ){ extra = -l - u; uv = float2(0,0); }
    if( alternate == 4 ){ extra =  l + u; uv = float2(1,1); }
    if( alternate == 5 ){ extra = -l + u; uv = float2(0,1); }


      o.worldPos = (v.pos) + extra * _Size;
      o.eye = _WorldSpaceCameraPos - o.worldPos;
      o.nor =v.nor;
      o.uv = v.uv;
      o.uv2 = uv;
      o.id = base;
      o.debug = v.debug;
      o.type = whichType;
      o.pos = mul (UNITY_MATRIX_VP, float4(o.worldPos,1.0f));


  return o;

}

      //Pixel function returns a solid color for each point.
      float4 frag (varyings v) : COLOR {
        float3 col = 1;

      
        if( v.type <= 4 ){
          col = float3(1,0,0);
        }
        if( v.type <= 2 ){
          col = float3(0,0,1);
        }

        if( v.type <= 1 ){
           col = float3(0,1,0);
        }

        if( v.type <= 0 ){
           col = 1;
        }
          return float4(col,1 );
      }

      ENDCG

    }
  }


}
