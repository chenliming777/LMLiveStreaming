//
//  LMStreamingBuffer.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMAudioFrame.h"
#import "LMVideoFrame.h"

/** current buffer status */
typedef NS_ENUM(NSUInteger, LMStreamingState) {
    LMStreamingIncrease = 0,    //< 缓冲区状态好可以增加码率
    LMStreamingDecline = 1      //< 缓冲区状态差应该降低码率
};

@class LMStreamingBuffer;
/** this two method will control videoBitRate */
@protocol LMStreamingBufferDelegate <NSObject>
@optional
/** 当前buffer变动（增加or减少） 根据buffer中的updateInterval时间回调*/
- (void)streamingBuffer:(nullable LMStreamingBuffer * )buffer bufferState:(LMStreamingState)state;
@end

@interface LMStreamingBuffer : NSObject

/** The delegate of the buffer. buffer callback */
@property (nullable,nonatomic, weak) id <LMStreamingBufferDelegate> delegate;

/** current frame buffer */
@property (nonatomic, strong, readonly) NSMutableArray <LMFrame*>* _Nonnull list;

/** buffer count max size default 1000 */
@property (nonatomic, assign) NSUInteger maxCount;

/** add frame to buffer */
- (void)appendObject:(nullable LMFrame*)frame;

/** pop the first frome buffer */
- (nullable LMFrame*)popFirstObject;

/** remove all objects from Buffer */
- (void)removeAllObject;

@end
