//
//  LMVideoFrame.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMFrame.h"

@interface LMVideoFrame : LMFrame

@property (nonatomic, assign) BOOL isKeyFrame;
@property (nonatomic, strong) NSData *sps;
@property (nonatomic, strong) NSData *pps;

@end
