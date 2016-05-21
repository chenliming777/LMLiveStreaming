//
//  LMStreamRtmpSocket.h
//  LMLiveStreaming
//
//  Created by admin on 16/5/18.
//  Copyright © 2016年 live Interactive. All rights reserved.
//

#import "LMStreamSocket.h"

@interface LMStreamRtmpSocket : NSObject<LMStreamSocket>

#pragma mark - Initializer
///=============================================================================
/// @name Initializer
///=============================================================================
- (nullable instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nullable instancetype)new UNAVAILABLE_ATTRIBUTE;

@end
