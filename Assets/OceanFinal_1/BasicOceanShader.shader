// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BasicOceanShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveDepthMap ("_WaveDepthMap",2D)= "white" {}
        _WaveNormalMap("wave Normal Map", 2D) = "white" {}
        _FoamTexture ("Foam Texture", 2D) = "white" {}
        _DepthMap ("DepthMap", 2D) = "white" {}
        _RDMain ("RDMain", 2D) = "white" {}
        _DepthNoiseMap ("DepthNoiseMap", 2D) = "white" {}
        _SkyBox("_Skybox",Cube) = "default" {}
        _WaveSize("_WaveSize" , Vector ) = (0,0,0,0)
        _WaveDirection("_WaveDirection" , Vector ) = (0,0,0,0)
        _WaveSize1("_WaveSize1" , Vector ) = (0,0,0,0)
        _WaveDirection1("_WaveDirection1" , Vector ) = (0,0,0,0)
        _WaveSize2("_WaveSize2" , Vector ) = (0,0,0,0)
        _WaveDirection2("_WaveDirection2" , Vector ) = (0,0,0,0)
        _WaveSizeMultiplier("_WaveSizeMultiplier" , float ) = 0
        _WaveHeightMultiplier("_WaveHeightMultiplier" , float ) = 0
        _WaveSpeedMultiplier("_WaveSpeedMultiplier" , float ) = 0


        
        _DepthCamPos("_DepthCamPos" , Vector ) = (0,0,0,0)
        _DepthCamSize("_DepthCamSize" , float ) = 0
        _DepthCamNear("_DepthCamNear" , float ) = 0
        _DepthCamFar("_DepthCamFar" , float ) = 0
        _RDDepthMultiplier("_RDDepthMultiplier" , float ) =3


        _NormalMapSize("_NormalMapSize",float) = 10
        _NormalMapPower("_NormalMapPower",float) = 10


        _RaySize("_RaySize" , float ) = 0
    
    }
    SubShader
    {
               LOD 100
        Tags { "Queue" = "Geometry+10" }

        GrabPass
        {
            "_BackgroundTexture"
        }
        Pass
        {

     
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _CameraDepthTexture, _WaterBackground;



            sampler2D _NormalMap;
            sampler2D _RDMain;
			sampler2D _BackgroundTexture;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;

                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                float3 normal: TEXCOORD4;
                float3 tangent : TEXCOORD5;
                float3 binormal : TEXCOORD6;

                float3 t1 : TEXCOORD7;
                float3 t2 : TEXCOORD8;
                float3 t3 : TEXCOORD9;

                float3 world : TEXCOORD10;

                float2 waveUV1 : TEXCOORD11;
                float2 waveUV2 : TEXCOORD12;
                float2 waveUV3 : TEXCOORD13;

                float4 screenPos : TEXCOORD14;

            };

            sampler2D _MainTex;
            sampler2D _DepthMap;
            sampler2D _WaveDepthMap;
            sampler2D _WaveNormalMap;
            sampler2D _FoamTexture;
            sampler2D _DepthNoiseMap;
            samplerCUBE _SkyBox;

            float _WaveSizeMultiplier;
            float _WaveHeightMultiplier;
            float _WaveSpeedMultiplier;
            float2 _WaveSize;
            float2 _WaveDirection;
            
            float2 _WaveSize1;
            float2 _WaveDirection1;
            
            float2 _WaveSize2;
            float2 _WaveDirection2;

            float _RDDepthMultiplier;


            float _RaySize;


            float _Size;

                      
            uniform float3 _DepthCamPos;
           uniform float _DepthCamSize;
           uniform float _DepthCamNear;
           uniform float _DepthCamFar;

            float2 getDepthLookup( float3 pos ){

                float3 base = pos - _DepthCamPos;
                float2 b = base.xz;

                b /= _DepthCamSize;
                
                b += 1;
                b /= 2;
                

                return b;

            }


            float3 getDepthLocation( float3 pos ){
                float2 uv = getDepthLookup(pos);

                float d = 1-tex2Dlod(_DepthMap , float4(uv,0,0)).r;

                float3 fPos = float3(pos.x,_DepthCamPos.y-_DepthCamNear - (_DepthCamFar-_DepthCamNear) * d,pos.z);//(float3(uv.x,0,uv.y) * 2 - 1) * _DepthCamSize + _DepthCamPos + float3(0,-1,0) * ( (_DepthCamFar-_DepthCamNear) * (1-d));


                return fPos;

            }




            float3 getOffsetPos( float3 pos  , float2 uv){
                
                float3 fPos = pos;

                float3 d = getDepthLocation( pos );
                float deltaD = 0;// 1/(fPos.y - d.y);



                float2 waveUV1 = ( pos.xz + deltaD) * _WaveSizeMultiplier*_WaveSize  + _WaveSpeedMultiplier * _WaveDirection * _Time.y;
                float2 waveUV2 = ( pos.xz + deltaD) * _WaveSizeMultiplier*_WaveSize1 + _WaveSpeedMultiplier * _WaveDirection1 * _Time.y;
                float2 waveUV3 = ( pos.xz + deltaD) * _WaveSizeMultiplier*_WaveSize2 + _WaveSpeedMultiplier * _WaveDirection2 * _Time.y;

                float depthVal1 = tex2Dlod( _WaveDepthMap , float4(waveUV1,0,0));
                float depthVal2 = tex2Dlod( _WaveDepthMap , float4(waveUV2,0,0));
                float depthVal3 = tex2Dlod( _WaveDepthMap , float4(waveUV3,0,0));

                fPos.y += (depthVal1 + depthVal2 + depthVal3) * _WaveHeightMultiplier;

                

               float4 rdCol = tex2Dlod(_RDMain,float4(uv,0,0));

               fPos.y += _RDDepthMultiplier *rdCol.x;


                return fPos;
            }

            float3 getOffsetNor( float3 pos , float2 uv ){

                float3 eps = float3(1,0,0);

                float3 p1 = getOffsetPos( pos + eps ,uv + eps.xy * .01);
                float3 p2 = getOffsetPos( pos - eps ,uv - eps.xy * .01);

                float3 p3 = getOffsetPos( pos + eps.yyx ,uv+ eps.yx * .01);
                float3 p4 = getOffsetPos( pos - eps.yyx ,uv- eps.yx * .01);


                return normalize( cross( (p2-p1)*1000, (p4-p3)*1000 ));

            }


       
     
float3 hsv(float h, float s, float v)
{
  return lerp( float3( 1.0 , 1, 1 ) , clamp( ( abs( frac(
    h + float3( 3.0, 2.0, 1.0 ) / 3.0 ) * 6.0 - 3.0 ) - 1.0 ), 0.0, 1.0 ), s ) * v;
}

            v2f vert (appdata v)
            {
                v2f o;

                //float

                float3 fPos = v.vertex;

                fPos = mul( unity_ObjectToWorld , float4(fPos , 1) ).xyz;
                fPos = getOffsetPos( fPos , v.uv );

                //float2  = getDepthLocation(fPos);

                


                float3 fNor = getOffsetNor(fPos,v.uv);

                float3 fTan = cross( fNor , v.tangent );
                fTan = normalize(cross( fNor , fTan ));

   

                o.vertex = mul( UNITY_MATRIX_VP , float4(fPos,1));       

                
                //fNor = normalize( mul(unity_ObjectToWorld , float4(fNor,0)).xyz );
                //fTan = normalize( mul(unity_ObjectToWorld , float4(fTan,0)).xyz );

                float3 bi = cross(fNor, fTan.xyz);


                
                // output the tangent space matrix
                o.t1 =  float3(fTan.x, bi.x, fNor.x);
                o.t2 =  float3(fTan.y, bi.y, fNor.y);
                o.t3 =  float3(fTan.z, bi.z, fNor.z);

                o.normal = fNor;
                o.uv = v.uv;

                o.world = fPos;//mul( unity_ObjectToWorld , float4(fPos , 1) ).xyz;


                o.screenPos = ComputeScreenPos( o.vertex );

                return o;
            }


            float _NormalMapSize;
            float _NormalMapPower;

            float3 MapNormal(  v2f v  ){
                float3 tnormal = UnpackNormal(tex2D(_WaveNormalMap, v.uv * _NormalMapSize));
                // transform normal from tangent to world space
                float3 n;
                n.x = dot(v.t1, tnormal);
                n.y = dot(v.t2, tnormal);
                n.z = dot(v.t3, tnormal);

                return normalize(lerp(v.normal, n, _NormalMapPower));
            }

float hash( float n ){
        return frac(sin(n)*43758.5453);
      }

     float3 getDepthLocation2( float3 pos ){
                float2 uv = getDepthLookup(pos);

                float d = 1-tex2D(_DepthMap , uv).r;

                float3 fPos = float3(pos.x,_DepthCamPos.y-_DepthCamNear - (_DepthCamFar-_DepthCamNear) * d,pos.z);//(float3(uv.x,0,uv.y) * 2 - 1) * _DepthCamSize + _DepthCamPos + float3(0,-1,0) * ( (_DepthCamFar-_DepthCamNear) * (1-d));


                return fPos;

            }  

            fixed4 frag (v2f v) : SV_Target
            {
                

                float3 fNor = MapNormal(v);


                float2 depthLookUp = getDepthLookup( v.world );

                float3 underground = getDepthLocation(v.world);

                float d = -(underground.y - v.world.y);
                

float depthDelta =  d;



                float3 eye = normalize(v.world - _WorldSpaceCameraPos);

                float3 refl = reflect( eye , fNor );
                
                float m = -dot( eye , v.normal);

               //eye += .03 *UNITY_MATRIX_V[1].xyz * hash( v.world.x  + _Time.x );//sin(1000*length(v.world.x));
               //eye += .03 *UNITY_MATRIX_V[2].xyz * hash( v.world.y  + _Time.x * 3 );;

                eye = normalize(eye);

                
                float3 refr = refract( normalize(eye) , -normalize(fNor) ,.5);

                int count = 20;
                for( int i = 0; i < 20; i++ ){
                    
                    float3 p = v.world + refr * float(i) * _RaySize;

                    
                    underground = getDepthLocation2(p);
                    d = -(underground.y - p.y);

                    float noiseSample = tex2D( _DepthNoiseMap , p.xz * .3 );

                    if( d < noiseSample * 1.3 ){
                        count = i;
                        break;
                    }


                }

                float3 c = lerp( 1 , 0 , float(count)/20);




                float4 reflCol = texCUBE( _SkyBox , refl );

                float4 col = 1;
                float d2 = tex2D(_DepthMap , depthLookUp).r;
                col.xyz  = reflCol.xyz;// * (1+m);//fNor * .5 + .5;
                col.xyz = lerp( float3(.2,.5,1), col , saturate(length(col.xyz) * .4));
               // col.xyz += float3(.2,.5,1);


               float4 rdCol = tex2D(_RDMain,v.uv);

                col.xyz = lerp( c *c, col , saturate(length(col.xyz) * .4));//-underground.y * .1;//tex2D(_DepthMap , depthLookUp);
                if( count <= 2 ){
                    col = 1;
                }

                col += rdCol.x;


      float4 distortedPosition = mul( UNITY_MATRIX_VP , float4(v.world + refr * 10,1));       
      
      float4 reflectedPosition = mul( UNITY_MATRIX_VP , float4(v.world + refl * 30,1));       

   
       float4 screenPos = ComputeScreenPos( distortedPosition);
       float4 screenPos2 = ComputeScreenPos( reflectedPosition);

    float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, screenPos);
    float depth = LinearEyeDepth(depthSample).r;


    float4 bgTexture = tex2Dproj(_BackgroundTexture, screenPos);
    float4 reflTexture = tex2Dproj(_BackgroundTexture, screenPos2);

    
    float depthSample2 =tex2Dproj(_CameraDepthTexture, screenPos);

    //depth = depthSample2;

// apply depth texture
				/*float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
				float depth = LinearEyeDepth(depthSample).r;

				// create foamline
				float foamLine = 1 - saturate(_DepthFactor * (depth - input.screenPos.w));
				float4 foamRamp = float4(tex2D(_DepthRampTex, float2(foamLine, 0.5)).rgb, 1.0);

				// sample main texture
				float4 albedo = tex2D(_MainTex, input.texCoord.xy);

			    float4 col = _Color * foamRamp * albedo;*/


//col = lerp( bgTexture , float4(0,1,0,1), .003*depth);

col = reflTexture;
col += lerp( bgTexture , float4(.04,.1,.2,1), saturate(.008*depth));

if( abs(depthDelta) < 10){
    col = 1;
}

                col += rdCol.x;

col = saturate(col);


col *= tex2D(_MainTex,float2(length(col) * .3 + .4,0));



         half4 skyData =UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refl);
         half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR);

         col.xyz = skyColor * .8;



              // col *= 5;
              // col = floor(col);
              // col /= 5;

              // col *= .5;
              // col += .5;
                
                return col;
            }
            ENDCG
        }
    }
}
