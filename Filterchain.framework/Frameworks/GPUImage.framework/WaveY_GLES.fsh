 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform highp float slider;
// uniform highp float time;
 uniform highp float amplitude;
 
 void main()
 {
     highp vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
    // uv = vec2(uv.x+sin(uv.y*10.0)/5.0*slider, uv.y+sin(uv.y*500.0)*amplitude*slider*0.1);
     uv.y += sin(uv.x*10.0)/5.0*slider;
     uv.y += sin(uv.x*30.0)*amplitude*slider*0.1;
     
     highp vec4 color = texture2D(inputImageTexture, uv);
     gl_FragColor = color;
 }
