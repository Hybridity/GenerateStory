 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; // Camera/Main texture texture
 
 uniform float slider;
// uniform float time;
// uniform float amplitude;
// uniform float randNum; // Receives a single random number each frame in range 0.0-1.0

 void main()
 {
     // Get the colours from the textures
     vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     
     // Get texture coordinates
     highp vec4 invertedColor = vec4(((slider*0.5+0.5) - originalColor.rgb), originalColor.w);
     // Output
     gl_FragColor = invertedColor;
 }
