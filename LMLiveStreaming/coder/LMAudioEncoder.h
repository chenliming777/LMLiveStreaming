//
//  LMAudioEncoder.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LMAudioFrame.h"
#import "LMAudioStreamingConfiguration.h"

@protocol LMAudioEncoder;
/// 编码器编码后回调
@protocol LMAudioEncodeDelegate <NSObject>
@required
- (void)audioEncoder:(nullable id<LMAudioEncoder>)encoder audioFrame:(nullable LMAudioFrame*)frame;
@end

/// 编码器抽象的接口
@protocol LMAudioEncoder <NSObject>
@required
- (void)encodeAudioData:(AudioBufferList)inBufferList timeStamp:(uint64_t)timeStamp;
- (void)stopEncoder;
@optional
- (nullable instancetype)initWithAudioStreamConfiguration:(nullable LMAudioStreamingConfiguration*)configuration;
- (void)setDelegate:(nullable id<LMAudioEncodeDelegate>)delegate;
- (nullable NSData*)adtsData:(NSInteger)channel rawDataLength:(NSInteger)rawDataLength;
@end

