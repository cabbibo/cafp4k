Shader "IMMAT/CAF/Sparkles"
{
    Properties
    {
        _MainTex("_MainTex", 2D) = "white" {}

        _Color( "Color" , color ) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
//Blend One One // Additive
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            #include "../Chunks/Struct16.cginc"
            #include "../Chunks/hsv.cginc"
              

            struct v2f { 
                float4 pos : SV_POSITION; 
                float2 uv : TEXCOORD1; 
                float3 world : TEXCOORD3; 
                float pID : TEXCOORD2; 
                float3 nor :NORMAL; 
            };
  float4 _Color;

  sampler2D _MainTex;

            StructuredBuffer<Vert> _VertBuffer;
            StructuredBuffer<int> _TriBuffer;

            v2f vert ( uint vid : SV_VertexID )
            {
                v2f o;
                int pID = vid/6;
                Vert v = _VertBuffer[_TriBuffer[vid]];
                o.pos = mul (UNITY_MATRIX_VP, float4(v.pos,1.0f));
                o.uv = v.uv;
                o.nor = v.nor;
                o.world = v.pos;
                o.pID = float(pID);
                return o;
            }

            fixed4 frag (v2f v) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, v.uv.yx);

                if( col.a < 0.6 ){discard;}

                col.xyz = hsv( sin( v.pID) *.1,.4,col.a);// col.a * col.a * col.a * .1;

                //col.xyz = normalize(v.nor) * .5 + .5;

                float3 eye = _WorldSpaceCameraPos - v.world;

                float3 refl = reflect( normalize(eye), v.nor);// )


         half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refl);
         half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);
                col.xyz *= 2*skyColor;
                return col;
            }

            ENDCG
        }
    }
}
