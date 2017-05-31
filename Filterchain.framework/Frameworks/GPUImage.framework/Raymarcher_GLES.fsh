 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; // Camera/Main texture texture
 
 uniform float slider;
 uniform float time;
 uniform float amplitude;
 uniform float randNum; // Receives a single random number each frame in range 0.0-1.0
 
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
 
 vec3 spheres(vec2 uv) {
     vec3 r = normalize(vec3(uv, 1.0));
     vec3 o = vec3(time, 1.0, slider*time+time*amplitude*0.3);
     float t = trace(o, r);
     float fog = 1.0/ (1.0 + t * t * 0.1);
     vec3 fc = vec3(fog);
     return fc;
 }
 
 void main()
 {
     // Get the colours from the textures
     vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     // Get texture coordinates
     vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
     uv = uv * 2.0 - 1.0;
     highp vec3 s = spheres(uv);
     //
//     uv.x *= iResolution.x/iResolution.y;
     

     //
     
     // Output
     gl_FragColor = vec4(s,1.0)*originalColor+originalColor*0.5;
//     gl_FragColor = vec4(amplitude, amplitude, 0.0, 1.0);
 }
