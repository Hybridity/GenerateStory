 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; // Camera/Main texture texture
 
 uniform float slider;
 uniform float time;
 uniform float amplitude;
 //uniform float randNum; // Receives a single random number each frame in range 0.0-1.0
 
 float map(vec3 p) {
     float radius = 0.2;
     vec3 q = fract(p) * 2.0 - 1.0;
     return length(q) - radius+0.05*sin(time);
 }
 
 float trace(vec3 o, vec3 r) {
     float t = 0.0;
     for (int i = 0; i < 16; ++i) {
         vec3 p = o + r * t;
         float d = map(p);
         t += d * 0.5;
     }
     return t;
 }
 
 void main()
 {
     // Get the colours from the textures
     vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     // Get texture coordinates
     vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
     uv = uv * 2.0 - 1.0;
     
     //
//     uv.x *= iResolution.x/iResolution.y;
     vec3 r = normalize(vec3(uv, 1.0));
     vec3 o = vec3(time, amplitude, slider*time);
     float t = trace(o, r);
     float fog = 1.0/ (1.0 + t * t * 0.1);
     vec3 fc = vec3(fog);

     //
     
     // Output
     gl_FragColor = vec4(fc,1.0)*originalColor+originalColor*0.5;
 }
 
