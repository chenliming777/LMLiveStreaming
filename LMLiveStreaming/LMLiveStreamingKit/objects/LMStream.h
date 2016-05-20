//
//  LMStream.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/// 流状态
typedef NS_ENUM(NSUInteger, LMStreamState){
    /// 未知状态，初始化时状态被设定为未知
    LMStreamStateUnknow = 0,
    /// 连接中
    LMStreamStateConnecting,
    /// 已连接
    LMStreamStateConnected,
    /// 重新连接中
    LMStreamStateRconnecting,
    /// 已断开
    LMStreamStateDisconnected,
    /// 连接出错
    LMStreamStateError
};

typedef NS_ENUM(NSUInteger,LMStreamSocketErrorCode) {
    LMStreamSocketError_ConnectSocket    = 0,///< 连接socket失败
    LMStreamSocketError_Verification     = 1,///< 验证服务器失败
    LMStreamSocketError_ReConnectTimeOut = 2 ///< 重新连接服务器超时
};


@interface LMStream : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *streamId;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, assign) CGSize videoSize;

@end
