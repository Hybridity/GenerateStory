 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; // Camera/Main texture
 
 uniform float controlVariable;
 uniform float time;
 //uniform float inputAmplitude;
 //uniform float randNum; // Receives a single random number each frame in range 0.0-1.0

 // These are random functions I found here and there on the internet.
 // It's all on an MIT licence.
 // https://github.com/ashima/webgl-noise
 // ...except for rand() which I got from here:
 // https://github.com/staffantan/unity-vhsglitch
 
 highp vec3 hash31(highp float p)
{
    vec3 p3 = fract(vec3(p) * vec3(.16532,.17369,.15787));
    p3 += dot(p3.xyz, p3.yzx + 19.19);
    return fract(vec3(p3.x * p3.y, p3.x*p3.z, p3.y*p3.z));
}
 
 highp vec3 hash33(highp vec3 p)
{
    p = fract(p * vec3(.16532,.17369,.15787));
    p += dot(p.zxy, p+19.19);
    return fract(vec3(p.x * p.y, p.x*p.z, p.y*p.z));
}
 
 float rand(vec3 col){
     return fract(sin( dot(col.xyz ,vec3(12.9898,78.233,45.5432) )) * 43758.5453)*-1.0;
 }
 
 highp vec4 taylorInvSqrt(highp vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}
 // Unused, from prototyping stage. Keeping this for future reference
 mediump vec4 grayscaleGradient(mediump float t) {
     mediump vec4 lines = vec4(mod(t, 0.1));
     return vec4(lines);
 }
  // Unused, from prototyping stage. Keeping this for future reference
 highp vec4 makeGradient(highp vec2 coord) {
     highp float gradient = coord.y;
     gradient *= sin(controlVariable)*mod(time, 5.);
     highp vec4 color = vec4(vec3(gradient), 1.);
     
     return vec4(color);
 }
 
 // This creates a number of horizontal bands at a specified speed
 highp vec4 distortion(highp vec2 coord, lowp float numLines, lowp float speed) {
     numLines *= 4.0; // This will give you *roughly* as many lines as you asked for...
     coord.y -= time*speed*0.07;
     highp float gradient = sin(coord.y*numLines);//+cos(coord.x*numLines*10.);
    
     highp vec4 color = vec4(vec3(gradient), 1.);
     return vec4(color);
 }

 // Function for generating randomly located (and sized) white lines (not ready and unsused atm)
 highp vec4 randLine(highp vec2 coord, lowp float numLines, lowp float speed, highp vec3 r) {
     numLines *= numLines; // This will give you *roughly* as many lines as you asked for...
     coord.y -= time*speed*r.r*0.3;
     coord.x -= time*speed*r.g*0.1;
     highp float gradient;
     if (r.r < 0.3) {
         gradient = sin(coord.y*numLines)*sin(coord.x*10.*r.g);
     }
     else {
//         gradient = sin(coord.y*numLines);
     }
     
     highp vec4 color = vec4(vec3(gradient), 1.);
     return vec4(color);
 }
 
 void main()
 {
     // Get the colours from the textures
     // TODO: Convert this to a single input shader, libraryColor is now unused
     vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
     
     // Get texture coordinates
     vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
     // Random colour (based on originalColour input)
     highp vec4 randVec = vec4(vec3(rand(originalColor.rgb*vec3(0.001))), 1.0);
     
     // Create horizontal bands using the gradient function distortion(coord, numLines, speed)
     // This is kind of like additive synthesis
     highp vec4 gradientColor = distortion(uv, 5., 0.5)+distortion(uv, 15.5, 0.23)+distortion(uv, 444., 0.27);
     // Low frequency carrier wave for the distorted signal
     gradientColor *= distortion(uv, 1., 0.03);
     
     // Apply another LFO carrier wave for variable effect
     highp vec4 noiseCarrierBand = distortion(uv, 1., 0.075)+distortion(uv, 2., 0.03);
     gradientColor *= noiseCarrierBand;

     // Hash based noise
     highp vec4 noiseField = vec4(hash33(gradientColor.rgb), 1.0);
     // Only make noise where the carrier waves (gradientColour) occurs.
     noiseField *= gradientColor*randVec;
     noiseField *= noiseCarrierBand; // Exaggerate a little bit
     
     // Move some pixels out of place in our inputTexture (using noiseField)
     highp vec4 remap = texture2D(inputImageTexture, vec2(textureCoordinate.x-noiseField.g*controlVariable*0.05, textureCoordinate.y));

     // Blending
     highp vec4 outputColor;
     // Dim the noise field
     noiseField *= vec4(vec3(0.3), 1.0);
     // Add remapped and noiseField vectors for final output
     outputColor = remap+noiseField;
     
     gl_FragColor = outputColor;
 }
