precision highp float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture; // Camera/Main texture texture

uniform float slider;
uniform float time;
//uniform float amplitude;
//uniform float randNum; // Receives a single random number each frame in range 0.0-1.0

uniform float minX;
uniform float maxX;
uniform float minY;
uniform float maxY;

//uniform float leftEyeX;
//uniform float leftEyeY;
//uniform float rightEyeX;
//uniform float rightEyeY;
uniform float mouthX;
uniform float mouthY;
//uniform float faceAngle;
//uniform float isSmiling;


highp vec4 distortion(highp vec2 uv) {
    highp float br = uv.x*sin(time*9.0);
    highp vec4 pattern = vec4(br*uv.x,br*uv.x,br*uv.x,1.0);
    return pattern;
}

float dist(vec2 p0, vec2 pf){return sqrt((pf.x-p0.x)*(pf.x-p0.x)+(pf.y-p0.y)*(pf.y-p0.y));}

// UV Bulge Distortion (only distorts coordinates)
highp vec2 bulgeDistortion(highp vec2 uv, highp vec2 center, float seed) {
    // seed is for time offset
    highp float aspectRatio = 1.0; // TODO: make this a uniform
    highp float radius = distance(maxX, minX)*0.7; // TODO make this dynamic
    highp float scale = 0.15;
    
    highp vec2 textureCoordinateToUse = vec2(uv.x, (uv.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
    highp float dist = distance(center, textureCoordinateToUse);
    textureCoordinateToUse = uv;
    
    if (dist < radius)
    {
        textureCoordinateToUse -= center;
        highp float percent = 1.0 - ((radius - dist) / radius) * scale * slider * sin(time+seed);
        percent = percent * percent * percent;
        
        textureCoordinateToUse = textureCoordinateToUse * percent;
        textureCoordinateToUse += center;
    }
    
    return textureCoordinateToUse;
}


void main()
{
    // Get the colours from the textures
    vec4 originalColor = texture2D(inputImageTexture, textureCoordinate);
    
    // Get texture coordinates
    vec2 uv = vec2(textureCoordinate.x, textureCoordinate.y);
    vec4 outputColor = texture2D(inputImageTexture, uv);
    // Face center
    highp vec2 faceCenter = vec2(distance(maxX, minX)*0.5+minX, distance(maxY, minY)*0.5+minY);
    // Be
    // Radial gradient
    highp vec2 screenResolution = vec2(480.0,480.0); // TODO: MAKE THIS A UNIFORM
    float d = dist(screenResolution.xy*faceCenter,gl_FragCoord.xy)*(sin(time)+3.5)*0.003;
    highp vec4 gradientColor = mix(vec4(1.0, 1.0, 1.0, 1.0), vec4(0.0, 0.0, 0.0, 1.0), d)*slider;
    
    highp vec4 remap;
    highp float directionX;
    highp float directionY;
    if (uv.x < faceCenter.x) {
        directionX = -1.0;
    }
    if (uv.x > faceCenter.x) {
        directionX = 1.0;
    }
    if (uv.y < faceCenter.y) {
        directionY = -1.0;
    }
    if (uv.y > faceCenter.y) {
        directionY = 1.0;
    }
    remap= texture2D(inputImageTexture, vec2(uv.x+gradientColor.r*directionX, uv.y+gradientColor.r*directionY));
    
    // Face bounds one liner
    if (uv.x > minX && uv.x < maxX && uv.y > minY && uv.y < maxY) {
        //         outputColor = vec4(1.0,0.0,0.0,1.0);
    }
    
    // Larger face area
    float offset = 0.1; // Solve this with CGAffineTransformScale?
    if (uv.x > minX-offset && uv.x < maxX+offset && uv.y > minY-offset && uv.y < maxY+offset) {
        
    }
    
    // Output
    //outputColor = max(bulgeDistortion(uv), originalColor);
    highp vec2 distUV = bulgeDistortion(uv, vec2(mouthX, mouthY), 0.11);
    distUV = bulgeDistortion(distUV, vec2(minX, minY), 0.21);
    distUV = bulgeDistortion(distUV, vec2(maxX, minY), 0.33);
    distUV = bulgeDistortion(distUV, vec2(maxX, maxY), 0.47);
    distUV = bulgeDistortion(distUV, vec2(minX, maxY), 0.59);
    
    highp vec4 distortedColor = texture2D(inputImageTexture, distUV);
    
    //     outputColor = distortedColor;
    //     outputColor = vec4(bulgeDistortion(uv, faceCenter) + originalColor) / 2.0;
    gl_FragColor = distortedColor;//remap+gradientColor;//outputColor+gradientColor;
}
