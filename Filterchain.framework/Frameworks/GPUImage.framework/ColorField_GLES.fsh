 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform highp float controlVariable;
 uniform highp float timeVariable;
 uniform highp float audioVariable;
 
 mediump vec3 hueGradient(mediump float t) {
     mediump vec3 p = abs(fract(t + vec3(1.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0);
     return (clamp(p - 1.0, 0.0, 1.0));
 }
 
 mediump vec3 grayscaleGradient(mediump float t) {
     return vec3(t);
 }
 
 mediump vec3 grayscaleGradient2D(mediump vec2 hnit) {
//     mediump vec3 result = vec3(hnit.x, hnit.y, 1.0); // blue, magenta, cyan, white
     mediump vec3 result = vec3(hnit.x)*vec3(hnit.y); // real grayscale
     return result;
 }
 
 mediump vec3 bmcwField(mediump vec2 hnit) {
     mediump vec3 result = vec3(hnit.x, hnit.y, controlVariable); // blue, magenta, cyan, white
     return result;
 }

 mediump vec3 redCorner(mediump vec2 hnit) {
     mediump vec3 result = vec3(hnit.x)*vec3(hnit.y)*vec3(1.0,0.0,0.0);
     return result;
 }
 
 lowp vec3 colorField(mediump vec2 hnit) {
     lowp float intensity = 1.0+controlVariable;
     // Offset coordinates
//     x = length * cos (angle);
//     y = length * sin (angle);
     
     // Time
     lowp float gOffset = controlVariable;
     lowp float speed = (1.0-gOffset);
     
     lowp float t = 0.5+abs(sin(timeVariable*speed)*0.3);
     lowp float t2 = 0.5+abs(sin(timeVariable*speed*0.8)*0.5);
     lowp float t3 = 0.5+abs(sin(timeVariable*speed*0.6)*0.5);
     lowp float t4 = 0.5+abs(sin(timeVariable*speed*0.7)*0.5);
     // Gradient offset
     
     // Corner positions
     
     lowp vec2 ul = vec2(1.0*gOffset-hnit)*t; // upper left
     lowp vec2 ur = vec2(hnit.x, 1.0*gOffset-hnit.y)*t2; // upper right
     lowp vec2 ll = vec2(1.0*gOffset-hnit.x, hnit.y)*t3; // lower left
     lowp vec2 lr = hnit*gOffset*t4; // lower right (unmodified hnit)

     // Modify positions
     
//     ul = vec2(ul.x*cos(timeVariable*0.1), ul.y*sin(timeVariable*0.01));
//     ur = vec2(ur.x*cos(timeVariable*0.2), ur.y*sin(timeVariable*0.02));
//     ll = vec2(ll.x*cos(timeVariable*0.3), ll.y*sin(timeVariable*0.03));
//     lr = vec2(lr.x*cos(timeVariable*0.5), lr.y*sin(timeVariable*0.05));
     
     
     // Gradients
     lowp float modRate = sin(t2)*controlVariable;
     lowp vec3 red = vec3(lr.x*intensity)*vec3(lr.y)*vec3(1.0,modRate,0.0);
     lowp vec3 green = vec3(ul.x*intensity)*vec3(ul.y)*vec3(0.0,1.0,modRate*0.9);
     lowp vec3 blue = vec3(ur.x*intensity)*vec3(ur.y)*vec3(modRate*0.8,0.0,1.0);
     lowp vec3 yellow = vec3(ll.x*intensity)*vec3(ll.y)*vec3(1.0,1.0,modRate*0.7);
     
     // Mixing
//     mediump vec3 result = mix(blue, mix(red, green, 0.5), 0.5);
     lowp vec3 result = red + green +  blue + yellow;
     return result;
 }
 
 lowp vec4 colorFieldTwo(mediump vec2 hnit, highp float colorOffset, highp float speed) {
     lowp float intensity = 1.0+controlVariable;
     
     lowp float t = 0.5+abs(sin(timeVariable*speed)*0.23);
     lowp float t2 = 0.5+abs(sin(timeVariable*speed*0.4)*0.5);
     lowp float t3 = 0.5+abs(sin(timeVariable*speed*0.3)*0.5);
     lowp float t4 = 0.5+abs(sin(timeVariable*speed*0.35)*0.5);
     
     // Gradient positions
     lowp vec2 ul = vec2(1.0*controlVariable-hnit)*t; // upper left
     lowp vec2 ur = vec2(hnit.x, 1.0*controlVariable-hnit.y)*t2; // upper right
     lowp vec2 ll = vec2(1.0*controlVariable-hnit.x, hnit.y)*t3; // lower left
     lowp vec2 lr = hnit*controlVariable*t4; // lower right (unmodified hnit)
     
     // Gradients
     lowp float modRate = sin(t2)*controlVariable;
     lowp vec4 red = vec4(vec3(lr.x*intensity)*vec3(lr.y)*vec3(1.0-colorOffset,modRate,0.0), 1.0);
     lowp vec4 green = vec4(vec3(ul.x*intensity)*vec3(ul.y)*vec3(0.0+colorOffset,1.0,modRate*0.9), 1.0);
     lowp vec4 blue = vec4(vec3(ur.x*intensity)*vec3(ur.y)*vec3(modRate*0.8,0.0+colorOffset,1.0), 1.0);
     lowp vec4 yellow = vec4(vec3(ll.x*intensity)*vec3(ll.y)*vec3(1.0-colorOffset,1.0,modRate*0.7*colorOffset), 1.0);
     lowp vec4 cyan = vec4(vec3(lr.x*intensity)*vec3(lr.y)*vec3(0.0+colorOffset, 1.0-colorOffset, 1.0-colorOffset), 1.0);
     
     // Mixing
     lowp vec4 result = red + green +  blue + yellow + cyan;
     // Burn
     result *= vec4(vec3(4.0), 1.0);
     return result;
 }
 
 
 void main()
 {
     highp vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
     lowp vec4 color = texture2D(inputImageTexture, uv);
     lowp vec4 gradient = texture2D(inputImageTexture, uv);
     lowp vec4 inverseGradient = texture2D(inputImageTexture, uv);
     gradient = colorFieldTwo(uv, 0.0, 0.7);
     // Flip coordinates
     uv = vec2(1.0) - uv;
     inverseGradient = colorFieldTwo(uv, 0.5, 0.3); // Offset colours a bit
//     gradient += inverseGradient; // Add the two gradients
//     gradient = smoothstep(gradient, inverseGradient, color);
     highp vec4 outputColor = gradient+inverseGradient;//+color;
//     mediump float distanceFromReferencePoint = clamp(distance(gradient, inverseGradient), 0.0, 1.0);
     outputColor *= vec4(1.0+audioVariable*3.0);
     
//     highp vec4 outputColor = gradient + inverseGradient;
     gl_FragColor = outputColor;
//     gl_FragColor = mix(gradient + color, gradient, 0.5);
//     gl_FragColor = gradient;
 }
