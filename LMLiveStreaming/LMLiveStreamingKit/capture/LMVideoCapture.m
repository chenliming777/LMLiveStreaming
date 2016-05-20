//
//  LMVideoCapture.m
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMVideoCapture.h"
#import "GPUImage.h"
#import "LMGPUImageBeautyFilter.h"
#import "LMGPUImageEmptyFilter.h"

@interface LMVideoCapture ()

@property(nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property(nonatomic, strong) GPUImageOutput<GPUImageInput> *emptyFilter;
@property(nonatomic, strong) GPUImageCropFilter *cropfilter;
@property(nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) LMVideoStreamingConfiguration *configuration;

@end

@implementation LMVideoCapture

#pragma mark -- LifeCycle
- (instancetype)initWithVideoConfiguration:(LMVideoStreamingConfiguration *)configuration{
    if(self = [super init]){
        _configuration = configuration;
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_configuration.avSessionPreset cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
        _videoCamera.horizontallyMirrorRearFacingCamera = NO;
        _videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
        
        _gpuImageView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
        [_gpuImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCamera) name:CameraStatusClosedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCamera) name:CameraStatusOpenedNotification object:nil];
        
        self.beautyFace = YES;
    }
    return self;
}

- (void)dealloc{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_videoCamera stopCameraCapture];
}

#pragma mark -- Setter Getter
- (void)setRunning:(BOOL)running{
    if(_running == running) return;
    _running = running;
    
    if(!_running){
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [_videoCamera stopCameraCapture];
    }else{
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [_videoCamera startCameraCapture];
    }
}

- (void)setPreView:(UIView *)preView{
    if(_gpuImageView.superview) [_gpuImageView removeFromSuperview];
    [preView insertSubview:_gpuImageView atIndex:0];
}

- (UIView*)preView{
    return _gpuImageView.superview;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition{
    [_videoCamera rotateCamera];
    _videoCamera.frameRate = (int32_t)_configuration.videoFrameRate;
}

- (AVCaptureDevicePosition)captureDevicePosition{
    return [_videoCamera cameraPosition];
}

- (void)setTorchOn:(BOOL)torchOn{
    _videoCamera.torch = torchOn;
}

- (BOOL)torchOn{
    return  _videoCamera.isTorch;
}

- (void)setVideoFrameRate:(NSInteger)videoFrameRate{
    if(videoFrameRate <= 0) return;
    if(videoFrameRate == _videoCamera.frameRate) return;
    _videoCamera.frameRate = (uint32_t)videoFrameRate;
}

- (NSInteger)videoFrameRate{
    return _videoCamera.frameRate;
}

- (void)setBeautyFace:(BOOL)beautyFace{
    if(_beautyFace == beautyFace) return;
    
    _beautyFace = beautyFace;
    [_emptyFilter removeAllTargets];
    [_filter removeAllTargets];
    [_cropfilter removeAllTargets];
    [_videoCamera removeAllTargets];
    
    if(_beautyFace){
        _filter = [[LMGPUImageBeautyFilter alloc] init];
        CGFloat radiusInPixels = _configuration.isClipVideo ? 9 : 13;//////< 360  540 720 :////  9   9   13
        [(LMGPUImageBeautyFilter*)_filter setBlurRadiusInPixels:radiusInPixels];
        _emptyFilter = [[LMGPUImageEmptyFilter alloc] init];
    }else{
        _filter = [[LMGPUImageEmptyFilter alloc] init];
    }
    
    __weak typeof(self) _self = self;
    [_filter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
        [_self processVideo:output];
    }];
    
    if(_configuration.isClipVideo){///<  裁剪为16:9
        _cropfilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0.125, 0, 0.75, 1)];
        [_videoCamera addTarget:_cropfilter];
        [_cropfilter addTarget:_filter];
    }else{
        [_videoCamera addTarget:_filter];
    }
    
    if (beautyFace) {
        [_filter addTarget:_emptyFilter];
        if(_gpuImageView) [_emptyFilter addTarget:_gpuImageView];
    } else {
        if(_gpuImageView) [_filter addTarget:_gpuImageView];
    }
    
}

#pragma mark -- Custom Method
- (void) processVideo:(GPUImageOutput *)output{
    __weak typeof(self) _self = self;
    @autoreleasepool {
        GPUImageFramebuffer *imageFramebuffer = output.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFramebuffer pixelBuffer];
        if(pixelBuffer && _self.delegate && [_self.delegate respondsToSelector:@selector(captureOutput:pixelBuffer:)]){
            [_self.delegate captureOutput:_self pixelBuffer:pixelBuffer];
        }
    }
}

#pragma mark Notification
- (void)openCamera{
    [_videoCamera removeVideoInputs];
}

- (void)closeCamera{
    [_videoCamera addVideoInputs];
}

- (void)willEnterBackground:(NSNotification*)notification{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [_videoCamera pauseCameraCapture];
    runSynchronouslyOnVideoProcessingQueue(^{
        glFinish();
    });
}

- (void)willEnterForeground:(NSNotification*)notification{
    [_videoCamera resumeCameraCapture];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

@end
