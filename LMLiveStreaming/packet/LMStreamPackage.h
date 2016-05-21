//
//  LMStreamPackage.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LMAudioFrame.h"
#import "LMVideoFrame.h"

/// 编码器抽象的接口
@protocol LMStreamPackage <NSObject>
@required
- (nullable instancetype)initWithVideoSize:(CGSize)videoSize;
- (nullable NSData*)aaCPacket:(nullable LMAudioFrame*)audioFrame;
- (nullable NSData*)h264Packet:(nullable LMVideoFrame*)videoFrame;
- (void)reset;
@end

