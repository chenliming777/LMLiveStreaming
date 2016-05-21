//
//  LMStreamingSession.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LMStream.h"
#import "LMAudioFrame.h"
#import "LMVideoFrame.h"
#import "LMAudioStreamingConfiguration.h"
#import "LMVideoStreamingConfiguration.h"
#import "LMStreamDebug.h"

/// 流类型
typedef NS_ENUM(NSUInteger, LMStreamType){
    /// rtmp格式
    LMStreamRtmp = 0,
    /// tcp 传输flv格式
    LMStreamTcp = 1,
};

@class LMStreamingSession;
@protocol LMStreamingSessionDelegate <NSObject>

@optional
/** stream status changed will callback */
- (void)streamingSession:(nullable LMStreamingSession *)session streamStateDidChange:(LMStreamState)state;
/** stream debug info callback */
- (void)streamingSession:(nullable LMStreamingSession *)session debugInfo:(nullable LMStreamDebug*)debugInfo;
/** callback socket errorcode */
- (void)streamingSession:(nullable LMStreamingSession*)session errorCode:(LMStreamSocketErrorCode)errorCode;
@end

@interface LMStreamingSession : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/** The delegate of the capture. captureData callback */
@property (nullable,nonatomic, weak) id<LMStreamingSessionDelegate> delegate;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

/** The stream control upload and package*/
@property (nullable,nonatomic, strong) LMStream * stream;

/** The uploading control upload Data*/
@property (nonatomic, assign) BOOL uploading;

/** The preView will show OpenGL ES view*/
@property (nonatomic, strong,null_resettable) UIView *preView;

/** The captureDevicePosition control camraPosition ,default front*/
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;

/** The beautyFace control capture shader filter empty or beautiy */
@property (nonatomic, assign) BOOL beautyFace;

/** The muted control callbackAudioData,muted will memset 0.*/
@property (nonatomic,assign) BOOL muted;

/** The status of the stream .*/
@property (nonatomic,assign,readonly) LMStreamState state;

/** The showDebugInfo control streamInfo and uploadInfo(1s) *.*/
@property (nonatomic,assign) BOOL showDebugInfo;

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
- (nullable instancetype)initWithAudioConfiguration:(nullable LMAudioStreamingConfiguration *)audioConfiguration videoConfiguration:(nullable LMVideoStreamingConfiguration*)videoConfiguration streamType:(LMStreamType)streamType NS_DESIGNATED_INITIALIZER;

@end

