 // Note:
 // Shader is broken. Tried some refactoring in here, take a look at original.
precision highp float;
 
 varying vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform float slider;
 highp vec2 tileSize;

 uniform float numTiles;
 uniform int colorOn;
 
 void main()
 {
     tileSize = vec2(0.125, 0.07142857142857142);
     vec2 xy = textureCoordinate;
     xy = xy - mod(xy, tileSize);
     
     vec4 lumcoeff = vec4(0.299,0.587,0.114,0.0);
     
     vec4 inputColor = texture2D(inputImageTexture, xy);
     float lum = dot(inputColor,lumcoeff);
     lum = 1.0 - lum;
     
     float stepsize = 1.0 / numTiles*slider*144;
     float lumStep = (lum - mod(lum, stepsize)) / stepsize;
     
     float rowStep = 1.0 / tileSize.x;
     float x = mod(lumStep, rowStep);
     float y = floor(lumStep / rowStep);
     
     vec2 startCoord = vec2(float(x) *  tileSize.x, float(y) * tileSize.x);
     vec2 finalCoord = startCoord + ((textureCoordinate - xy) * (tileSize / tileSize));
     
     vec4 color = texture2D(inputImageTexture, finalCoord);
     if (colorOn == 1) {
         color = color * inputColor;
     }
     gl_FragColor = color;
     
 }

