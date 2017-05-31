 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;

 uniform lowp float slider;
 uniform highp float time;
// uniform highp float threshold;
 
 const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
 const highp vec4 shadowCol = vec4(0.55, 0.24, 0.25, 1.0);
 const highp vec4 highlightCol = vec4(0.04, 0.38, 1.0, 1.0);

 void main()
 {
     // Duotone
     highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     highp float luminance = dot(textureColor.rgb, W);
     highp float thresholdResult = step(slider, luminance);
     highp vec4 bw = vec4(vec3(thresholdResult), textureColor.w)*highlightCol;
     highp vec4 bwInvert = vec4(vec3(1.0 - thresholdResult), textureColor.w)*shadowCol;
     highp vec4 duoTone = max(bw, bwInvert);
     
     // Features/Shadow Details
     highp float thresholdResultOffset = step((slider*0.5), luminance);
     highp vec4 features = vec4(vec3(1.0-thresholdResultOffset), 1.0);
     
     highp vec4 results = max(duoTone, floor(features));
     gl_FragColor = results;
 }
