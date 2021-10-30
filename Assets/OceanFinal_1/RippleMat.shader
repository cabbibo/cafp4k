Shader "Ocean/RippleMat"
{
    Properties
    {
        _RDLast ("tex2D", 2D) = "white" {}
        _Height ("tex2D", 2D) = "white" {}
        _TexelSize ("TexelSize", Vector) = (1.0, 1.0, 0.0, 0.0) 
        _Resolution ("Resolution", Vector) = (1.0, 1.0, 0.0, 0.0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float texel : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };


            float4x4 _Transform;

            sampler2D _RDLast;
            sampler2D _Height;
            sampler2D _DepthTexture;
            float4 _TexelSize;
            float4 _Resolution;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul( _Transform , float4(0, 0 , 0 , 1 )).xyz;
                float scale = mul( _Transform , float4(1, 0 , 0 , 0 )).x * 10;

                o.worldPos -= float3(v.uv.x -.5 , 0,v.uv.y-.5)* scale;
                o.texel = _TexelSize * scale;

                return o;
            }
            
        


            float2 _HitUV;
            float _Down;

/*
            // nine-point compact stencil of Laplacian operator
const float[9] stencil = float[](
  .05, .20, .05,
  .20, -1., .20,
  .05, .20, .05
);

// relative coordinates of 9x9 grid points
const float2[9] grid = float2[9](
    float2(-1.0,  1.0), float2(0.0,  1.0), float2(1.0,  1.0),
    float2(-1.0,  0.0), float2(0.0,  0.0), float2(1.0,  0.0),
    float2(-1.0, -1.0), float2(0.0, -1.0), float2(1.0, -1.0)
);



float4 sample1(sampler2D channel, vec2 uv) {

    //sample with a lerp based on boundary conditions
    float2 p = uv;

    float samp1 = tex2D(channel, uv);
    float depth = tex2D(_DepthTexture,uv).r;
    return lerp( samp1, float4(0.0, 0.0, 0.0, 1.0), saturate( depth * 100 - 90));
}


// values of a field stored in a texture on the grid
float[9] getField(sampler2D channel, float2 uv) {
	vec2 px = 1.0 * _TexelSize.xy;
    float[9] field;
    for (int i = 0; i < 9; i++) {
        float2 r = uv + px * grid[i];
        field[i] = sample1(channel, r).x;
    }
    return field;
}

// Laplacian of a field
float laplacian(float[9] samples) {
    float sum = 0.0;
    for (int i=0; i<9; i++) {
        sum += stencil[i] * samples[i];
    }
    return sum;
}
*/
float _Stencil[9];
float2 _Offsets[9];
//
//float c = 2.0; // wave speed <= 2
//float w = 0.2; // emission frequency
//float damp = 0.995; 

            float4 newHeight(float2 uv ,float texel ) {

             // float dif = terrainWorldPos( worldPos ).y - worldPos.y;

         
            _Stencil[0] = .05;
            _Stencil[1] = .20; 
            _Stencil[2] = .05;
            
            _Stencil[3] = .20; 
            _Stencil[4] = -1.0; 
            _Stencil[5] = .20; 

            _Stencil[6] = .05;
            _Stencil[7] = .20; 
            _Stencil[8] = .05;

            _Offsets[0] = float2( -1.0 , 1.0 );
            _Offsets[1] = float2(  0.0 , 1.0 ); 
            _Offsets[2] = float2(  1.0 , 1.0 );
            
            _Offsets[3] = float2( -1.0 , 0.0 ); 
            _Offsets[4] = float2(  0.0 , 0.0 );
            _Offsets[5] = float2(  1.0 , 0.0 ); 

            _Offsets[6] = float2( -1.0 , -1.0 );
            _Offsets[7] = float2(  0.0 , -1.0 ); 
            _Offsets[8] = float2(  1.0 , -1.0 );

            /*float sum = 0;
            sum += tex2D( _RDLast, uv+float2( -1.0 , 1.0 )*.5*_TexelSize.xy).x *.05;
            sum += tex2D( _RDLast, uv+float2(  0.0 , 1.0 )*.5*_TexelSize.xy).x *.20; 
            sum += tex2D( _RDLast, uv+float2(  1.0 , 1.0 )*.5*_TexelSize.xy).x *.05;
            
            sum += tex2D( _RDLast, uv+float2( -1.0 , 0.0 )*.5*_TexelSize.xy).x *.20; 
            sum += tex2D( _RDLast, uv+float2(  0.0 , 0.0 )*.5*_TexelSize.xy).x *-1.0;
            sum += tex2D( _RDLast, uv+float2(  1.0 , 0.0 )*.5*_TexelSize.xy).x *.20; 

            sum += tex2D( _RDLast, uv+float2( -1.0 , -1.0 )*.5*_TexelSize.xy).x *.05;
            sum += tex2D( _RDLast, uv+float2(  0.0 , -1.0 )*.5*_TexelSize.xy).x *.20; 
            sum += tex2D( _RDLast, uv+float2(  1.0 , -1.0 )*.5*_TexelSize.xy).x *.05;

*/

            float sum = 0;
            for( int i =0; i < 9; i++ ){
                float h = tex2D(_RDLast, uv + _Offsets[i]*_TexelSize.xy  ).x;
                float d = tex2D(_DepthTexture,uv+_Offsets[i]*_TexelSize.xy).x;
                d = d*d*d*d*d*d*d*d*d*d;
                h = lerp( h , 0 , saturate(d * .3));

                if( d > .99 ){
                    h = 1;
                }else{
                    h *= 1-d*.1;
                }

                sum += h * _Stencil[i];

            }



                float2 c   = tex2D(_RDLast, uv  ).xy;
                float pressure = c.x;
                float oldPressure = c.y;
                float dt =.1;

                float val = 2.0 * pressure - oldPressure + .1 * dt * sum; // wave motion

                val *= .9995;

                val = clamp( val , -1,1);

                return  float4(val, pressure, sum, 1.0);// , -10, 10);

                
/*
                float h_n = tex2D(_RDLast, uv + float2(0., 1.) * _TexelSize.xy ).x;
                float h_e = tex2D(_RDLast, uv + float2(1., 0.) * _TexelSize.xy ).x;
                float h_s = tex2D(_RDLast, uv + float2(0., -1.) * _TexelSize.xy ).x;
                float h_w = tex2D(_RDLast, uv + float2(-1., 0.) * _TexelSize.xy ).x;

                float  m_n = tex2D(_DepthTexture,uv + float2(0., 1.) * _TexelSize.xy );
                float  m_e = tex2D(_DepthTexture,uv + float2(1., 1.) * _TexelSize.xy );
                float  m_s = tex2D(_DepthTexture,uv + float2(0., -1.) * _TexelSize.xy );
                float  m_w = tex2D(_DepthTexture,uv + float2(-1., 0.) * _TexelSize.xy );
                //float m_n = terrainWorldPos( worldPos  + float3( 0., 0,  1.) * texel* .1).y - worldPos.y;
                //float m_e = terrainWorldPos( worldPos  + float3( 1., 0,  0.) * texel* .1).y - worldPos.y;
                //float m_s = terrainWorldPos( worldPos  + float3( 0., 0, -1.) * texel* .1).y - worldPos.y;
                //float m_w = terrainWorldPos( worldPos  + float3(-1., 0,  0.) * texel* .1).y - worldPos.y;

               // if( )


               const float delta = .1;
                float edge = 0;
                 if(m_n > .99 ){   pVel *=1;edge = 1;}
                 if(m_e > .99 ){   pVel *=1;edge = 1;}
                 if(m_s > .99 ){   pVel *=1;edge = 1;}
                 if(m_w > .99 ){   pVel *=1;edge = 1;}

                 if( edge ){
                     pressure = pressure  * .9;
                     pVel *= .9;
                 }
               // if(m_e > .9 ){  h_e = 0 ;edge = 

                // Apply horizontal wave function
                pVel += delta * (-2.0 * pressure + h_e + h_w) / 4.0;
                // Apply vertical wave function (these could just as easily have been one line)
                pVel += delta * (-2.0 * pressure + h_n + h_s) / 4.0;


// Change pressure by pressure velocity
    pressure += delta * pVel;
    
    // "Spring" motion. This makes the waves look more like water waves and less like sound waves.
    pVel -= 0.01 * delta * pressure;
    
    // Velocity damping so things eventually calm down
    pVel *= 1.0 - 0.0005 * delta;
    
    // Pressure damping to prevent it from building up forever.
    pressure *= 0.999;*/
          

   /* if( _Time.y % 1000 > .1 ){
                return float4(val, pressure, sum, 1.0);
    }else{
            return float4(0,0,0,1);
    }*/
            }

            fixed4 frag (v2f v) : SV_Target
            {
        
                    float4 result = newHeight(v.uv , v.texel);



                    float dist = length(v.uv-_HitUV);
                    float delta = dist - (_Down * .01);
                    if( delta < 0 ){

                        float v = delta / (_Down * .01);
                       // result.x += (.01- length(v.uv-_HitUV))*100;
                        result.x = -saturate(-v * _Down*_Down);// saturate((.1- length(v.uv-_HitUV))) ;
                    }

                    float d = tex2D(_DepthTexture,v.uv).x;
                    result.z = (result.x - result.y ) * 100;

                    //result = d*d*d*d*d*d*d*d*d*d;
                   // float tPos = terrainWorldPos( v.worldPos ).y- v.worldPos.y;

                    return result;//fixed4(result.x , result.y  ,1, 1.0);
                
            }
            ENDCG
        }
    }
}
