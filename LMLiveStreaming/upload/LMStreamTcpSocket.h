//
//  LMStreamTcpSocket.h
//  LMLiveStreaming
//
//  Created by admin on 16/5/3.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMStreamSocket.h"

@interface LMStreamTcpSocket : NSObject<LMStreamSocket>
#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
