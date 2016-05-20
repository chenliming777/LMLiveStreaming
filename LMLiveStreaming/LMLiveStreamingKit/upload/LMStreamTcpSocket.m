//
//  LMStreamTcpSocket.m
//  LMLiveStreaming
//
//  Created by admin on 16/5/3.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMStreamTcpSocket.h"
#import "GCDAsyncSocket.h"
#import "LMFlvPackage.h"

static const NSInteger RetryTimesBreaken = 60;///<  重连3分钟  3秒一次 一共60次
static const NSInteger RetryTimesMargin = 3;
const NSInteger TCP_RECEIVE_TIMEOUT = -1;

@interface LMStreamTcpSocket () <LMStreamingBufferDelegate,GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket * socket;
@property (nonatomic, strong) dispatch_queue_t socketQueue;
@property (nonatomic, strong) LMStreamingBuffer *buffer;
@property (nonatomic, strong) LMStream *stream;
@property (nonatomic, weak) id<LMStreamSocketDelegate> delegate;
@property (nonatomic, strong) id<LMStreamPackage> package;
@property (nonatomic, strong) LMStreamDebug *debugInfo;
@property (nonatomic, assign) BOOL showStremDebug;

@property (nonatomic, assign) BOOL isSending;
@property (nonatomic, assign) BOOL isConnecting;
@property (nonatomic, assign) BOOL isReconnecting;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, assign) NSInteger retryTimes4netWorkBreaken;

@end

@implementation LMStreamTcpSocket

- (instancetype)initWithStream:(LMStream*)stream{
    if(!stream) @throw [NSException exceptionWithName:@"LFStreamTcpSocket init error" reason:@"stream is nil" userInfo:nil];
    if(self = [super init]){
        _stream = stream;
    }
    return self;
}

#pragma mark -- LFStreamSocket
- (void) start{
    if(!_stream) return;
    if(_isConnecting) return;
    if(_socket.isConnected) return;
    [self clean];
    
    if(self.showStremDebug){
        self.debugInfo.streamId = self.stream.streamId;
        self.debugInfo.uploadUrl = self.stream.url;
        self.debugInfo.videoSize = self.stream.videoSize;
        self.debugInfo.isRtmp = NO;
    }
    
    if(![self.socket connectToHost:_stream.host onPort:_stream.port error:nil]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
            [self.delegate socketStatus:self status:LMStreamStateError];
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketDidError:errorCode:)]){
            [self.delegate socketDidError:self errorCode:LMStreamSocketError_ConnectSocket];
        }
        return;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
        [self.delegate socketStatus:self status:LMStreamStateConnecting];
    }
    _isConnecting = YES;
}

- (void) stop{
    [self.socket disconnect];
    [self clean];
}

- (void)setShowDebug:(BOOL)showDebug{
    _showStremDebug = showDebug;
}

- (void)sendFrame:(LMFrame *)frame{
    __weak typeof(self) _self = self;
    dispatch_async(self.socketQueue, ^{
        __strong typeof(_self) self = _self;
        if(!frame) return;
        if([frame isKindOfClass:[LMAudioFrame class]]){
            NSData *packageData = [self.package aaCPacket:(LMAudioFrame*)frame];///< 打包flv
            if(packageData) frame.data = packageData;
        }else{
            NSData *packageData = [self.package h264Packet:(LMVideoFrame*)frame];///< 打包flv
            if(packageData) frame.data = packageData;
        }
        
        if(frame.header){///< flvHeader 插入到队列最前面去
            LMFrame *headerFrame = [self.buffer.list firstObject] ? [self.buffer.list firstObject] : frame;
            NSMutableData * mutableData = [[NSMutableData alloc] init];
            [mutableData appendData:frame.header];
            [mutableData appendData:headerFrame.data];
            headerFrame.data = mutableData;
        }
        [self.buffer appendObject:frame];
        [self sendFrame];
    });
}

- (void)setDelegate:(id<LMStreamSocketDelegate>)delegate{
    _delegate = delegate;
}

#pragma mark -- CustomMethod
- (void)sendFrame{
    if(!self.isSending && self.buffer.list.count > 0 && _isConnected){
        self.isSending = YES;
        LMFrame *frame = [self.buffer popFirstObject];
        if(self.showStremDebug){
            self.debugInfo.dataFlow += frame.data.length;
            if(CACurrentMediaTime()*1000 - self.debugInfo.timeStamp < 1000) {
                self.debugInfo.bandwidth += frame.data.length;
                if([frame isKindOfClass:[LMAudioFrame class]]){
                    self.debugInfo.capturedAudioCount ++;
                }else{
                    self.debugInfo.capturedVideoCount ++;
                }
                self.debugInfo.unSendCount = self.buffer.list.count;
            }else {
                self.debugInfo.currentBandwidth = self.debugInfo.bandwidth;
                self.debugInfo.currentCapturedAudioCount = self.debugInfo.capturedAudioCount;
                self.debugInfo.currentCapturedVideoCount = self.debugInfo.capturedVideoCount;
                if(self.delegate && [self.delegate respondsToSelector:@selector(socketDebug:debugInfo:)]){
                    [self.delegate socketDebug:self debugInfo:self.debugInfo];
                }
                
                self.debugInfo.bandwidth = 0;
                self.debugInfo.capturedAudioCount = 0;
                self.debugInfo.capturedVideoCount = 0;
                self.debugInfo.timeStamp = CACurrentMediaTime()*1000;
            }
        }
        [self.socket writeData:frame.data withTimeout:TCP_RECEIVE_TIMEOUT tag:1];
    }
}

- (void)clean{
    _isConnected = NO;
    _isConnecting = NO;
    _isReconnecting = NO;
    _isSending = NO;
    _retryTimes4netWorkBreaken = 0;
    self.debugInfo = nil;
    [self.buffer removeAllObject];
}

// 断线重连
-(void) reconnect {
    _isReconnecting = NO;
    if(_isConnected) return;
    if([self.socket isConnected]) return;
    
    if(![self.socket connectToHost:_stream.host onPort:_stream.port error:nil]){
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
            [self.delegate socketStatus:self status:LMStreamStateError];
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketDidError:errorCode:)]){
            [self.delegate socketDidError:self errorCode:LMStreamSocketError_ConnectSocket];
        }
        return;
    }
}

#pragma mark -- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    [sock readDataWithTimeout:-1 tag:0];
    if(_isConnected) return;
    _isConnected = YES;
    _isConnecting = NO;
    _isReconnecting = NO;
    _retryTimes4netWorkBreaken = 0;// 计数器清零
    self.isSending = NO;
    [self.package reset];
    if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
        [self.delegate socketStatus:self status:LMStreamStateConnected];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"onSocket:%p socketDidDisconnectWithError:%@", sock, err);
    if(err){
        if(self.retryTimes4netWorkBreaken++ < RetryTimesBreaken && !self.isReconnecting){
            _isConnected = NO;
            _isConnecting = NO;
            _isReconnecting = YES;
            
            [self.socket disconnect];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(RetryTimesMargin * NSEC_PER_SEC)), self.socketQueue, ^{
                [self reconnect];
            });
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
                [self.delegate socketStatus:self status:LMStreamStateRconnecting];
            }
        }else if(self.retryTimes4netWorkBreaken >= RetryTimesBreaken){
            if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
                [self.delegate socketStatus:self status:LMStreamStateError];
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(socketDidError:errorCode:)]){
                [self.delegate socketDidError:self errorCode:LMStreamSocketError_ReConnectTimeOut];
            }
        }
    }else{
        [self clean];
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketStatus:status:)]){
            [self.delegate socketStatus:self status:LMStreamStateDisconnected];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if(tag > 0){
        self.isSending = NO;
        [self sendFrame];
    }
}

#pragma mark --BufferDelegate
- (void)streamingBuffer:(nullable LMStreamingBuffer*)buffer bufferState:(LMStreamingState)state{
    if(self.isConnected){
        if(self.delegate && [self.delegate respondsToSelector:@selector(socketBufferStatus:status:)]){
            [self.delegate socketBufferStatus:self status:state];
        }
    }
}

#pragma mark -- Getter Setter
- (dispatch_queue_t)socketQueue{
    if(!_socketQueue){
        _socketQueue = dispatch_queue_create("com.youku.LMStreaming.live.socketQueue", NULL);
    }
    return _socketQueue;
}

- (GCDAsyncSocket*)socket{
    if(!_socket){
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.socketQueue socketQueue:self.socketQueue];
    }
    return _socket;
}

- (LMStreamingBuffer*)buffer{
    if(!_buffer){
        _buffer = [[LMStreamingBuffer alloc] init];
        _buffer.delegate = self;
    }
    return _buffer;
}

- (id<LMStreamPackage>)package{
    if(!_package){
        _package = [[LMFlvPackage alloc] initWithVideoSize:_stream.videoSize];
    }
    return _package;
}

- (LMStreamDebug*)debugInfo{
    if(!_debugInfo){
        _debugInfo = [[LMStreamDebug alloc] init];
    }
    return _debugInfo;
}

@end
