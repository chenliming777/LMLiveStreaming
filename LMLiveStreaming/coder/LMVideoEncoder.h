//
//  LMVideoEncoder.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMVideoFrame.h"
#import "LMVideoStreamingConfiguration.h"

@protocol LMVideoEncoder;
/// 编码器编码后回调
@protocol LMVideoEncodeDelegate <NSObject>
@required
- (void)videoEncoder:(nullable id<LMVideoEncoder>)encoder videoFrame:(nullable LMVideoFrame*)frame;
@end

/// 编码器抽象的接口
@protocol LMVideoEncoder <NSObject>
@required
- (void)encodeVideoData:(nullable CVImageBufferRef)pixelBuffer timeStamp:(uint64_t)timeStamp;
- (void)stopEncoder;
- (void)setVideoBitRate:(NSUInteger)videoBitRate;
@optional
- (nullable instancetype)initWithVideoStreamConfiguration:(nullable LMVideoStreamingConfiguration*)configuration;
- (void)setDelegate:(nullable id<LMVideoEncodeDelegate>)delegate;
@end

