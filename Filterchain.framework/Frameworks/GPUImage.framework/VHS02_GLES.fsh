 precision highp float;
 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture; // Camera/Main texture
 
 uniform float slider;
 uniform float time;
 uniform float amplitude;
 uniform float randNum; // Receives a single random number each frame in range 0.0-1.0

 highp vec2 uv;
 
 highp vec3 hash33(highp vec3 p)
{
    p = fract(p * vec3(.16532,.17369,.15787));
    p += dot(p.zxy, p+19.19);
    return fract(vec3(p.x * p.y, p.x*p.z, p.y*p.z));
}
 
 highp float rand(vec3 col)
{
    return fract(sin( dot(col.xyz ,vec3(12.9898,78.233,45.5432) )) * 43758.5453)*-1.0;
}
 
 highp vec4 distortion(highp vec2 coord, lowp float numLines, lowp float speed) {
     speed *= 1.+amplitude*3.;
     numLines *= randNum*slider;// This will give you *roughly* as many lines as you asked for...
     numLines -= numLines*amplitude;
     coord.y -= time*speed*0.07;//*randNum;
     highp float gradient = sin(coord.y*numLines);//+cos(coord.x*numLines*10.);
     
     highp vec4 color = vec4(vec3(gradient), 1.);
     return vec4(color);
 }
 
 highp vec4 carrierDistortion(float freq)
{
    return distortion(uv, freq, 1.0)+distortion(uv, 3., 1.0);
}
 
 void main()
 {
     float scaledSlider = slider*3.;
     scaledSlider += 451.57;
     
     
     uv = vec2(textureCoordinate.x, textureCoordinate.y);
     highp vec4 originalColor = texture2D(inputImageTexture, uv);
     
     // Random colour (based on originalColour input)
     highp vec4 randVec = vec4(vec3(rand(originalColor.rgb*vec3(0.9))), 1.0);
     // Create horizontal bands using the gradient function distortion(coord, numLines, speed)f
     // This is kind of like additive synthesis
     highp vec4 gradientColor = distortion(uv, 5.*(1.0-amplitude), 0.5)+distortion(uv, 7.5*(1.0+amplitude), 1.0)+distortion(uv, 11.*(1.0-amplitude), 1.0);     // Low frequency carrier wave for the distorted signal
     gradientColor *= distortion(uv, 4.*(amplitude+1.), 1.0);
     
     // Apply another LFO carrier wave for variable effect
     highp vec4 noiseCarrierBand = carrierDistortion(1.0);
     noiseCarrierBand *= carrierDistortion(amplitude*slider*100.);
//     gradientColor *= noiseCarrierBand*scaledSlider*4.0;
//     gradientColor = max(gradientColor, noiseCarrierBand)+min(gradientColor, noiseCarrierBand);
     
     // Simpler carrier wave
     highp vec4 carrier = distortion(uv, 3.0+mod(time*0.002*-1.0, 1.0)*10., 0.1);
     carrier *= gradientColor;
     float maskThreshold = 0.9;
     if (carrier.r >= maskThreshold) {
         carrier = vec4(vec3(0.0), 1.0);
     }
     carrier *= noiseCarrierBand;
     carrier *= distortion(uv, 400., 0.1)*randVec;
     carrier *= distortion(uv, 450.3, 0.11)*randVec;
     
//      Move some pixels out of place in our inputTexture (using noiseField)
     highp vec4 remap;
     remap = texture2D(inputImageTexture, vec2(uv.x-carrier.r*0.005, uv.y));
     float remapGain = 0.05;
     if (mod(uv.x, 0.5) == 0.0) {
         remapGain *= -1.0; // Change remap direction
     }
     remap = texture2D(inputImageTexture, vec2(uv.x+carrier.r*remapGain, uv.y));
     
     
     highp vec4 black = vec4(vec3(0.), 1.);
     highp vec4 outputColor = max(carrier, black);
     outputColor += remap;
     
     // Blending
     
     gl_FragColor = outputColor;//remap+gradientColor*0.0005;//+originalColor;
 }

