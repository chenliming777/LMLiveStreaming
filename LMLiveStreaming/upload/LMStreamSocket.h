//
//  LMStreamSocket.h
//  LMLiveStreaming
//
//  Created by admin on 16/5/3.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMStream.h"
#import "LMStreamingBuffer.h"
#import "LMStreamDebug.h"

@protocol LMStreamSocket ;
@protocol LMStreamSocketDelegate <NSObject>

/** callback buffer current status (回调当前缓冲区情况，可实现相关切换帧率 码率等策略)*/
- (void)socketBufferStatus:(nullable id<LMStreamSocket>)socket status:(LMStreamingState)status;
/** callback socket current status (回调当前网络情况) */
- (void)socketStatus:(nullable id<LMStreamSocket>)socket status:(LMStreamState)status;
/** callback socket errorcode */
- (void)socketDidError:(nullable id<LMStreamSocket>)socket errorCode:(LMStreamSocketErrorCode)errorCode;
@optional
/** callback debugInfo */
- (void)socketDebug:(nullable id<LMStreamSocket>)socket debugInfo:(nullable LMStreamDebug*)debugInfo;
@end

@protocol LMStreamSocket <NSObject>

- (nullable instancetype)initWithStream:(nullable LMStream*)stream;
- (void) start;
- (void) stop;
- (void) sendFrame:(nullable LMFrame*)frame;
- (void) setDelegate:(nullable id<LMStreamSocketDelegate>)delegate;
- (void) setShowDebug:(BOOL)showDebug;

@end
