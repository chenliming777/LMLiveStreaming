//
//  LMStreamingBuffer.m
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMStreamingBuffer.h"
#import "NSMutableArray+YYAdd.h"

static const NSUInteger defaultSortBufferMaxCount = 10;///< 排序10个内
static const NSUInteger defaultUpdateInterval = 1;///< 更新频率为1s
static const NSUInteger defaultCallBackInterval = 30;///< 30s计时一次
static const NSUInteger defaultSendBufferMaxCount = 1000;///< 最大缓冲区为1000

@interface LMStreamingBuffer (){
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray <LMFrame*>*sortList;
@property (nonatomic, strong, readwrite) NSMutableArray <LMFrame*>*list;
@property (nonatomic, strong) NSMutableArray *thresholdList;

/** 处理buffer缓冲区情况 */
@property (nonatomic, assign) NSInteger currentInterval;
@property (nonatomic, assign) NSInteger callBackInterval;
@property (nonatomic, assign) NSInteger updateInterval;
@property (nonatomic, assign) NSInteger increaseCount;
@property (nonatomic, assign) NSInteger declineCount;
@property (nonatomic, assign) BOOL startTimer;

@end

@implementation LMStreamingBuffer

- (instancetype)init{
    if(self = [super init]){
        _lock = dispatch_semaphore_create(1);
        self.updateInterval = defaultUpdateInterval;
        self.callBackInterval = defaultCallBackInterval;
        self.maxCount = defaultSendBufferMaxCount;
    }
    return self;
}

- (void)dealloc{
}

#pragma mark -- Custom
- (void)appendObject:(LMFrame*)frame{
    if(!frame) return;
    if(!_startTimer){
        _startTimer = YES;
        [self tick];
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if(self.sortList.count < defaultSortBufferMaxCount){
        [self.sortList addObject:frame];
    }else{
        ///< 排序
        [self.sortList addObject:frame];
        NSArray *sortedSendQuery = [self.sortList sortedArrayUsingFunction:frameDataCompare context:NULL];
        [self.sortList removeAllObjects];
        [self.sortList addObjectsFromArray:sortedSendQuery];
        /// 丢帧
        while (self.list.count >= self.maxCount) {
            [self removeExpireFrame];
        }
        /// 添加至缓冲区
        [self.list addObject:[self.sortList popFirstObject]];
    }
    dispatch_semaphore_signal(_lock);
}

- (LMFrame*)popFirstObject{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    LMFrame *firstFrame = [self.list popFirstObject];
    dispatch_semaphore_signal(_lock);
    return firstFrame;
}

- (void)removeAllObject{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.list removeAllObjects];
    dispatch_semaphore_signal(_lock);
}

- (void)removeExpireFrame{
    ///< 一共2步  第一步查找第一个I帧将I帧后数据都干掉  第二步查找2个帧将中间P帧干掉 （判断2个I帧中间如果没有P帧则将后面那个I帧干掉）
    if(self.list.count >= self.maxCount){
        BOOL isFirstFrame_I = NO;
        BOOL isSecondFrame_I = NO;
        NSMutableArray <LMFrame*> *expireFrames = [NSMutableArray new];
        NSInteger isFirstFrame_Index = 0;
        NSInteger isSecondFrame_Index = 0;
        
        for(NSInteger index = 0;index < self.list.count;index++){
            LMFrame *frame = [self.list objectAtIndex:index];
            if([frame isKindOfClass:[LMVideoFrame class]]){
                LMVideoFrame *videoFrame = (LMVideoFrame*)frame;
                if(videoFrame.isKeyFrame){
                    if(!isFirstFrame_I){
                        isFirstFrame_I = YES;
                        isFirstFrame_Index = index;
                        if(index != 0){
                            break;
                        }
                    }else{
                        isSecondFrame_I = YES;
                        isSecondFrame_Index = index;
                        break;
                    }
                }else{
                    [expireFrames addObject:frame];
                }
            }
            
        }
        if(isFirstFrame_I && isFirstFrame_Index != 0){
            if(expireFrames.count > 0){
                [self.list removeObjectsInArray:expireFrames];
            }else{
                NSRange r;
                r.location = 0;
                r.length = isFirstFrame_Index + 1;
                [self.list removeObjectsInRange:r];
            }
            return;
        }
        
        if(isFirstFrame_I && isSecondFrame_I){
            if(expireFrames.count > 0){
                [self.list removeObjectsInArray:expireFrames];
            }else{
                [self.list removeObjectAtIndex:isFirstFrame_Index];
            }
        }
    }
}

NSInteger frameDataCompare(id obj1, id obj2, void *context){
    LMFrame* frame1 = (LMFrame*) obj1;
    LMFrame *frame2 = (LMFrame*) obj2;
    
    if (frame1.timestamp == frame2.timestamp)
        return NSOrderedSame;
    else if(frame1.timestamp > frame2.timestamp)
        return NSOrderedDescending;
    return NSOrderedAscending;
}

- (LMStreamingState)currentBufferState{
    NSMutableArray *randomArray = [[NSMutableArray alloc] init];
    
    while ([randomArray count] < 20) {
        int r = arc4random() % ([self.thresholdList count] - 1);
        [randomArray addObject:[self.thresholdList objectAtIndex:r]];
    }
    
    NSInteger badCount = 0;
    
    for(NSNumber *number in randomArray){
        if(number.integerValue > 3){
            badCount ++;
            if(badCount >= 3){
                return LMStreamingDecline;
            }
        }
    }
    
    return LMStreamingIncrease;
}

#pragma mark -- Setter Getter
- (NSMutableArray*)list{
    if(!_list){
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray*)sortList{
    if(!_sortList){
        _sortList = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray*)thresholdList{
    if(!_thresholdList){
        _thresholdList = [[NSMutableArray alloc] init];
    }
    return _thresholdList;
}


#pragma mark -- 采样
- (void)tick{
    /** 采样 3个阶段   如果网络都是好或者都是差给回调 */
    _currentInterval += self.updateInterval;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.thresholdList addObject:@(self.list.count)];
    dispatch_semaphore_signal(_lock);
    
    if(self.currentInterval >= self.callBackInterval){
        LMStreamingState state = [self currentBufferState];
        if(state == LMStreamingIncrease){
            self.increaseCount += 1;
            self.declineCount = 0;
        }else{
            self.declineCount += 1;
            self.increaseCount = 0;
        }
        
        if(self.declineCount >= 3 || self.increaseCount >= 3){
            if(self.delegate && [self.delegate respondsToSelector:@selector(streamingBuffer:bufferState:)]){
                [self.delegate streamingBuffer:self bufferState:self.declineCount >= 3 ? LMStreamingDecline : LMStreamingIncrease];
            }
            self.increaseCount = 0;
            self.declineCount = 0;
        }
        
        self.currentInterval = 0;
        [self.thresholdList removeAllObjects];
    }
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.updateInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        [self tick];
    });
}

@end
