#import "LMGPUImageBeautyFilter.h"
#import "GPUImageGaussianBlurFilter.h"
#import "GPUImageTwoInputFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const KLMGPUImageBeautyFragmentShaderString = SHADER_STRING
( 
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; 
 
 uniform lowp float excludeCircleRadius;
 uniform lowp vec2 excludeCirclePoint;
 uniform lowp float excludeBlurSize;
 uniform highp float aspectRatio;
 //247  217  211

 void main()
 {
     lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
//     if((sharpImageColor.r > 0.172549 && sharpImageColor.g > 0.056863 && sharpImageColor.b > 0.038431 && sharpImageColor.r - sharpImageColor.g > 0.028823 && sharpImageColor.r -
//         sharpImageColor.b > 0.038823) || (sharpImageColor.r > 0.584314 && sharpImageColor.g > 0.623530 && sharpImageColor.b > 0.466667 && abs(sharpImageColor.r - sharpImageColor.b) <=0.058823 && sharpImageColor.r > sharpImageColor.b && sharpImageColor.g > sharpImageColor.b)){
     if((sharpImageColor.r > 0.372549 && sharpImageColor.g > 0.156863 && sharpImageColor.b > 0.078431 &&
         sharpImageColor.r - sharpImageColor.g > 0.058823 && sharpImageColor.r - sharpImageColor.b > 0.058823) ||
        (sharpImageColor.r > 0.784314 && sharpImageColor.g > 0.823530 && sharpImageColor.b > 0.666667 &&
         abs(sharpImageColor.r - sharpImageColor.b) <= 0.058823 && sharpImageColor.r > sharpImageColor.b && sharpImageColor.g > sharpImageColor.b)) {
         mediump float rpass;
         mediump float gpass;
         mediump float bpass;
         mediump float hpass;
            hpass = 0.5 / excludeBlurSize;
         //1280*720
         //bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.045455, 1.0);
         //960*540
         rpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*hpass, 1.0);
         gpass = min((sharpImageColor.g - blurredImageColor.g)*(sharpImageColor.g - blurredImageColor.g)*hpass, 1.0);
         bpass = min((sharpImageColor.b - blurredImageColor.b)*(sharpImageColor.b - blurredImageColor.b)*hpass, 1.0);

         gpass = max(rpass, gpass);
         bpass = max(gpass, bpass);
         
         bpass = min((0.5+255.0*(1.0*bpass+bpass*bpass*bpass*bpass+bpass*bpass*bpass)), 1.0);
         gl_FragColor = mix(sharpImageColor, blurredImageColor, 1.0-bpass);
         //gl_FragColor = vec4(0, 0, 0, 1.0);
     } else {
         mediump float rpass;
         mediump float gpass;
         mediump float bpass;
         mediump float hpass;
         hpass = 0.5 / excludeBlurSize;
         //1280*720
         //bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.045455, 1.0);
         //960*540
         rpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*hpass, 1.0);
         gpass = min((sharpImageColor.g - blurredImageColor.g)*(sharpImageColor.g - blurredImageColor.g)*hpass, 1.0);
         bpass = min((sharpImageColor.b - blurredImageColor.b)*(sharpImageColor.b - blurredImageColor.b)*hpass, 1.0);
         
         gpass = max(rpass, gpass);
         bpass = max(gpass, bpass);
         
         bpass = min((0.65+1.0*255.0*(1.0*bpass)), 1.0);
         //bpass = min((0.75+1.0*255.0*(1.0*bpass)), 1.0);
         //bpass = 0.79;
         gl_FragColor = mix(sharpImageColor, blurredImageColor, 1.0-bpass);
         //gl_FragColor = vec4(sharpImageColor.r, sharpImageColor.g, sharpImageColor.b,1.0);
         //gl_FragColor = vec4(0, 0, 0, 1.0);
     }

     mediump float r;
     mediump float g;
     mediump float b;
     r = min((gl_FragColor.r*2.0 - gl_FragColor.r*gl_FragColor.r), 1.0);
     g = min((gl_FragColor.g*2.0 - gl_FragColor.g*gl_FragColor.g), 1.0);
     b = min((gl_FragColor.b*2.0 - gl_FragColor.b*gl_FragColor.b), 1.0);
//     mediump float dis;
//     dis = distance(vec3(gl_FragColor.r, gl_FragColor.g, gl_FragColor.b), vec3(0.968627, 0.85098, 0.827451));
//     dis = dis / 1.532018;
//     r = min((gl_FragColor.r*dis+(1.0-dis)*0.968627), 1.0);
//     g = min((gl_FragColor.g*dis+(1.0-dis)*0.85098), 1.0);
//     b = min((gl_FragColor.b*dis+(1.0-dis)*0.827451), 1.0);

     r = min(0.81*gl_FragColor.r+0.19*r, 1.0);
     g = min(0.81*gl_FragColor.g+0.19*g, 1.0);
     b = min(0.81*gl_FragColor.b+0.19*b, 1.0);
     gl_FragColor = vec4(r, g, b, 1.0);

 }
);
#else
NSString *const KLMGPUImageBeautyFragmentShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform float excludeCircleRadius;
 uniform vec2 excludeCirclePoint;
 uniform float excludeBlurSize;
 uniform float aspectRatio;
 
 void main()
 {
//     vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
//     vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
//     
//     vec2 textureCoordinateToUse = vec2(textureCoordinate2.x, (textureCoordinate2.y * aspectRatio + 0.5 - 0.5 * aspectRatio));
//     float distanceFromCenter = distance(excludeCirclePoint, textureCoordinateToUse);
//     
//     gl_FragColor = mix(sharpImageColor, blurredImageColor, smoothstep(excludeCircleRadius - excludeBlurSize, excludeCircleRadius, distanceFromCenter));
     
     vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
     vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
     if(sharpImageColor.r > 0.372549/*0.372549*/) {
         mediump float bpass;
         bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.045455, 1.0);
         //bpass = min((sharpImageColor.r - blurredImageColor.r)*(sharpImageColor.r - blurredImageColor.r)*0.038462, 1.0);
         bpass = min((0.5+255.0*bpass), 1.0);
         gl_FragColor = mix(sharpImageColor, blurredImageColor, 1.0-bpass);
     } else {
         gl_FragColor = vec4(sharpImageColor.r, sharpImageColor.g, sharpImageColor.b,1.0);
     }
     mediump float r;
     mediump float g;
     mediump float b;
     r = min((gl_FragColor.r*2.0 - gl_FragColor.r*gl_FragColor.r), 1.0);
     g = min((gl_FragColor.g*2.0 - gl_FragColor.g*gl_FragColor.g), 1.0);
     b = min((gl_FragColor.b*2.0 - gl_FragColor.b*gl_FragColor.b), 1.0);
     
     r = min(0.62*gl_FragColor.r+0.38*r, 1.0);
     g = min(0.62*gl_FragColor.g+0.38*g, 1.0);
     b = min(0.62*gl_FragColor.b+0.38*b, 1.0);
     
     gl_FragColor = vec4(r, g, b, 1.0);
     
 }
);
#endif

@implementation LMGPUImageBeautyFilter

@synthesize excludeCirclePoint = _excludeCirclePoint, excludeCircleRadius = _excludeCircleRadius, excludeBlurSize = _excludeBlurSize;
@synthesize blurRadiusInPixels = _blurRadiusInPixels;
@synthesize aspectRatio = _aspectRatio;

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    hasOverriddenAspectRatio = NO;
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.texelSpacingMultiplier = 0.55;
    [self addFilter:blurFilter];
    
    // Second pass: combine the blurred image with the original sharp one
    selectiveFocusFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:KLMGPUImageBeautyFragmentShaderString];
    [self addFilter:selectiveFocusFilter];
    
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:selectiveFocusFilter atTextureLocation:1];
    
    // To prevent double updating of this filter, disable updates from the sharp image side    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, selectiveFocusFilter, nil];
    self.terminalFilter = selectiveFocusFilter;
    
    //self.blurRadiusInPixels = 5.0;
    //960*540
    self.blurRadiusInPixels = 13.0;
    //1280*720
    //self.blurRadiusInPixels = 11.0;
    
    self.excludeCircleRadius = 13.0;
    self.excludeCirclePoint = CGPointMake(0.5f, 0.5f);
    self.excludeBlurSize = 13.0;
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!hasOverriddenAspectRatio) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        _aspectRatio = (inputTextureSize.width / inputTextureSize.height);
        [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
    }
}

#pragma mark -
#pragma mark Accessors

- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    blurFilter.blurRadiusInPixels = newValue;
    _excludeCircleRadius = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeCircleRadius"];
    _excludeBlurSize = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeBlurSize"];
}

- (CGFloat)blurRadiusInPixels;
{
    return blurFilter.blurRadiusInPixels;
}

- (void)setExcludeCirclePoint:(CGPoint)newValue;
{
    _excludeCirclePoint = newValue;
    [selectiveFocusFilter setPoint:newValue forUniformName:@"excludeCirclePoint"];
}

- (void)setExcludeCircleRadius:(CGFloat)newValue;
{
    _excludeCircleRadius = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeCircleRadius"];
}

- (void)setExcludeBlurSize:(CGFloat)newValue;
{
    _excludeBlurSize = newValue;
    [selectiveFocusFilter setFloat:newValue forUniformName:@"excludeBlurSize"];
}

- (void)setAspectRatio:(CGFloat)newValue;
{
    hasOverriddenAspectRatio = YES;
    _aspectRatio = newValue;    
    [selectiveFocusFilter setFloat:_aspectRatio forUniformName:@"aspectRatio"];
}

@end
