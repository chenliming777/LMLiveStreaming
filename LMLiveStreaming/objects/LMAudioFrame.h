//
//  LMAudioFrame.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMFrame.h"

@interface LMAudioFrame : LMFrame

/// flv打包中aac的header
@property (nonatomic, strong) NSData *audioInfo;

@end
