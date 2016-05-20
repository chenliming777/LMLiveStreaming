//
//  LMVideoCapture.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMVideoStreamingConfiguration.h"
#import <AVFoundation/AVFoundation.h>

//相机开关(当正在预览时如果此时拍摄图片则发此通知)
#define CameraStatusOpenedNotification   @"CameraStatusOpenedNotification"
#define CameraStatusClosedNotification   @"CameraStatusClosedNotification"

@class LMVideoCapture;
/** LMVideoCapture callback videoData */
@protocol LMVideoCaptureDelegate <NSObject>
- (void)captureOutput:(nullable LMVideoCapture*)capture pixelBuffer:(nullable CVImageBufferRef)pixelBuffer;
@end

@interface LMVideoCapture : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/** The delegate of the capture. captureData callback */
@property (nullable,nonatomic, weak) id<LMVideoCaptureDelegate> delegate;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

/** The preView will show OpenGL ES view*/
@property (null_resettable,nonatomic, strong) UIView * preView;

/** The captureDevicePosition control camraPosition ,default front*/
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

/** The torchOn control camra torch*/
@property (nonatomic, assign) BOOL torchOn;

/** The beautyFace control capture shader filter empty or beautiy */
@property (nonatomic, assign) BOOL beautyFace;

/** The videoFrameRate control videoCapture output data count */
@property (nonatomic, assign) NSInteger videoFrameRate;

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 The designated initializer. Multiple instances with the same configuration will make the
 capture unstable.
 */
- (nullable instancetype)initWithVideoConfiguration:(nullable LMVideoStreamingConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end
