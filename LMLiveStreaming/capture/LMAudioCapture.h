//
//  LMAudioCapture.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMAudioStreamingConfiguration.h"
#import <AVFoundation/AVFoundation.h>

#pragma mark -- AudioCaptureNotification
/** compoentFialed will post the notification */
extern NSString *_Nullable const LFAudioComponentFailedToCreateNotification;

@class LMAudioCapture;
/** LMAudioCapture callback audioData */
@protocol LMAudioCaptureDelegate <NSObject>
- (void)captureOutput:(nullable LMAudioCapture*)capture audioBuffer:(AudioBufferList)inBufferList;
@end


@interface LMAudioCapture : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================

/** The delegate of the capture. captureData callback */
@property (nullable,nonatomic, weak) id<LMAudioCaptureDelegate> delegate;

/** The muted control callbackAudioData,muted will memset 0.*/
@property (nonatomic,assign) BOOL muted;

/** The running control start capture or stop capture*/
@property (nonatomic, assign) BOOL running;

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
- (nullable instancetype)initWithAudioConfiguration:(nullable LMAudioStreamingConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

@end
