using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Lasp;

namespace IMMATERIA {
public class BindLaspTexture : Binder
{ 
    public SpectrumToTexture spectrumTexture;

    public Form[] formBinds;
    public Body[] bodyBinds;

    public Life[] extraLives;
    

    public override void Bind(){
      toBind.BindTexture("_AudioMap" , () => spectrumTexture.texture );

      for( var i =0; i < extraLives.Length; i++ ){
          extraLives[i].BindTexture("_AudioMap" , () => spectrumTexture.texture );
      }
    }

    public override void WhileLiving( float v ){


        Texture t = spectrumTexture.texture;
        for( var i = 0;  i < bodyBinds.Length; i++ ){
            bodyBinds[i].mpb.SetTexture("_AudioMap" , t );
        }

         for( var i = 0;  i < formBinds.Length; i++ ){
            formBinds[i].mpb.SetTexture("_AudioMap" , t );
        }
        


    }




  }
}