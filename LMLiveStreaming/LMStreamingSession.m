//
//  LMStreamingSession.m
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/2.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMStreamingSession.h"
#import "LMVideoCapture.h"
#import "LMAudioCapture.h"
#import "LMHardwareVideoEncoder.h"
#import "LMHardwareAudioEncoder.h"
#import "LMStreamTcpSocket.h"
#import "LMStreamRtmpSocket.h"

@interface LMStreamingSession ()<LMAudioCaptureDelegate,LMVideoCaptureDelegate,LMAudioEncodeDelegate,LMVideoEncodeDelegate,LMStreamSocketDelegate>

///流媒体格式
@property (nonatomic, assign) LMStreamType streamType;
///音频配置
@property (nonatomic, strong) LMAudioStreamingConfiguration *audioConfiguration;
///视频配置
@property (nonatomic, strong) LMVideoStreamingConfiguration *videoConfiguration;
/// 声音采集
@property (nonatomic, strong) LMAudioCapture *audioCaptureSource;
/// 视频采集
@property (nonatomic, strong) LMVideoCapture *videoCaptureSource;
/// 音频编码
@property (nonatomic, strong) id<LMAudioEncoder> audioEncoder;
/// 视频编码
@property (nonatomic, strong) id<LMVideoEncoder> videoEncoder;
/// 上传
@property (nonatomic, strong) id<LMStreamSocket> socket;

@end

/**  时间戳 */
#define NOW (CACurrentMediaTime()*1000)
@interface LMStreamingSession ()

@property (nonatomic, assign) uint64_t timestamp;
@property (nonatomic, assign) BOOL isFirstFrame;
@property (nonatomic, assign) uint64_t currentTimestamp;

@end

@implementation LMStreamingSession

#pragma mark -- LifeCycle
- (instancetype)initWithAudioConfiguration:(LMAudioStreamingConfiguration *)audioConfiguration videoConfiguration:(LMVideoStreamingConfiguration *)videoConfiguration streamType:(LMStreamType)streamType{
    if(!audioConfiguration || !videoConfiguration) @throw [NSException exceptionWithName:@"LMStreamingSession init error" reason:@"audioConfiguration or videoConfiguration is nil " userInfo:nil];
    if(self = [super init]){
        _audioConfiguration = audioConfiguration;
        _videoConfiguration = videoConfiguration;
        _streamType = streamType;
    }
    return self;
}

- (void)dealloc{
    self.audioCaptureSource.running = NO;
    self.videoCaptureSource.running = NO;
}

#pragma mark -- CaptureDelegate
- (void)captureOutput:(nullable LMAudioCapture*)capture audioBuffer:(AudioBufferList)inBufferList{
    [self.audioEncoder encodeAudioData:inBufferList timeStamp:self.currentTimestamp];
}

- (void)captureOutput:(nullable LMVideoCapture*)capture pixelBuffer:(nullable CVImageBufferRef)pixelBuffer{
    [self.videoEncoder encodeVideoData:pixelBuffer timeStamp:self.currentTimestamp];
}

#pragma mark -- EncoderDelegate
- (void)audioEncoder:(nullable id<LMAudioEncoder>)encoder audioFrame:(nullable LMAudioFrame*)frame{
    if(self.uploading) [self.socket sendFrame:frame];//<上传
}

- (void)videoEncoder:(nullable id<LMVideoEncoder>)encoder videoFrame:(nullable LMVideoFrame*)frame{
    if(self.uploading) [self.socket sendFrame:frame];//<上传
}

#pragma mark -- LFStreamTcpSocketDelegate
- (void)socketStatus:(nullable id<LMStreamSocket>)socket status:(LMStreamState)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(streamingSession:streamStateDidChange:)]){
            [self.delegate streamingSession:self streamStateDidChange:status];
        }
    });
}

- (void)socketDidError:(nullable id<LMStreamSocket>)socket errorCode:(LMStreamSocketErrorCode)errorCode{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(streamingSession:errorCode:)]){
            [self.delegate streamingSession:self errorCode:errorCode];
        }
    });
}

- (void)socketDebug:(nullable id<LMStreamSocket>)socket debugInfo:(nullable LMStreamDebug*)debugInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(streamingSession:debugInfo:)]){
            [self.delegate streamingSession:self debugInfo:debugInfo];
        }
    });
}

- (void)socketBufferStatus:(nullable id<LMStreamSocket>)socket status:(LMStreamingState)status{
    NSInteger videoFrameRate = [_videoConfiguration videoFrameRate];
    NSUInteger videoBitRate = [_videoConfiguration videoBitRate];
    if(status == LMStreamingIncrease){
        if(videoFrameRate < _videoConfiguration.videoMaxFrameRate){
            ///< 增加帧率
            _videoConfiguration.videoFrameRate = videoFrameRate + 1;
            [_videoCaptureSource setVideoFrameRate:_videoConfiguration.videoFrameRate];
        }else{
            ///< 增加码率
            if(videoBitRate < _videoConfiguration.videoMaxBitRate){
                _videoConfiguration.videoBitRate = videoBitRate + 50*1024;
                [_videoEncoder setVideoBitRate:_videoConfiguration.videoBitRate];
            }
        }
    }else{
        if(videoFrameRate > _videoConfiguration.videoMinFrameRate){
            ///< 降低帧率
            _videoConfiguration.videoFrameRate = videoFrameRate - 1;
            [_videoCaptureSource setVideoFrameRate:_videoConfiguration.videoFrameRate];
        }else{
            ///< 降低码率
            if(videoBitRate > _videoConfiguration.videoMinBitRate){
                 _videoConfiguration.videoBitRate = videoBitRate - 50*1024;
                [_videoEncoder setVideoBitRate:_videoConfiguration.videoBitRate];
            }
        }
    }
}

#pragma mark -- Getter Setter
- (void)setRunning:(BOOL)running{
    if(_running == running) return;
    [self willChangeValueForKey:@"running"];
    _running = running;
    [self didChangeValueForKey:@"running"];
    self.videoCaptureSource.running = _running;
    self.audioCaptureSource.running = _running;
}

- (void)setShowDebugInfo:(BOOL)showDebugInfo{
    _showDebugInfo = showDebugInfo;
}

- (void)setUploading:(BOOL)uploading{
    if(!_stream && uploading) {
        @throw [NSException exceptionWithName:@"LMStreamingSession uploading error" reason:@"stream is nil " userInfo:nil];
        return;
    }
    if(_uploading == uploading) return;
    [self.socket setShowDebug:self.showDebugInfo];
    [self willChangeValueForKey:@"uploading"];
    _uploading = uploading;
    [self willChangeValueForKey:@"uploading"];
    _timestamp = 0;
    _isFirstFrame = YES;
    if(_uploading){
        [self.socket start];
    }else{
        [self.socket stop];
    }
}

- (void)setPreView:(UIView *)preView{
    [self.videoCaptureSource setPreView:preView];
}

- (UIView*)preView{
    return self.videoCaptureSource.preView;
}

- (void)setCaptureDevicePosition:(AVCaptureDevicePosition)captureDevicePosition{
    [self.videoCaptureSource setCaptureDevicePosition:captureDevicePosition];
}

- (AVCaptureDevicePosition)captureDevicePosition{
    return self.videoCaptureSource.captureDevicePosition;
}

- (void)setBeautyFace:(BOOL)beautyFace{
    [self.videoCaptureSource setBeautyFace:beautyFace];
}

- (BOOL)beautyFace{
    return self.videoCaptureSource.beautyFace;
}

- (void)setMuted:(BOOL)muted{
    [self.audioCaptureSource setMuted:muted];
}

- (BOOL)muted{
    return self.audioCaptureSource.muted;
}

- (LMAudioCapture*)audioCaptureSource{
    if(!_audioCaptureSource){
        _audioCaptureSource = [[LMAudioCapture alloc] initWithAudioConfiguration:_audioConfiguration];
        _audioCaptureSource.delegate = self;
    }
    return _audioCaptureSource;
}

- (LMVideoCapture*)videoCaptureSource{
    if(!_videoCaptureSource){
        _videoCaptureSource = [[LMVideoCapture alloc] initWithVideoConfiguration:_videoConfiguration];
        _videoCaptureSource.delegate = self;
    }
    return _videoCaptureSource;
}

- (id<LMAudioEncoder>)audioEncoder{
    if(!_audioEncoder){
        _audioEncoder = [[LMHardwareAudioEncoder alloc] initWithAudioStreamConfiguration:_audioConfiguration];
        [_audioEncoder setDelegate:self];
    }
    return _audioEncoder;
}

- (id<LMVideoEncoder>)videoEncoder{
    if(!_videoEncoder){
        _videoEncoder = [[LMHardwareVideoEncoder alloc] initWithVideoStreamConfiguration:_videoConfiguration];
        [_videoEncoder setDelegate:self];
    }
    return _videoEncoder;
}

- (id<LMStreamSocket>)socket{
    if(!_socket){
        if(self.streamType == LMStreamRtmp){
            _socket = [[LMStreamRtmpSocket alloc] initWithStream:self.stream];
        }else if(self.streamType == LMStreamTcp){
            _socket = [[LMStreamTcpSocket alloc] initWithStream:self.stream];
            self.stream.videoSize = self.videoConfiguration.videoSize;
        }
        [_socket setDelegate:self];
    }
    return _socket;
}

- (uint64_t)currentTimestamp{
    uint64_t currentts = 0;
    if(_isFirstFrame == true) {
        _timestamp = NOW;
        _isFirstFrame = false;
        currentts = 0;
    }
    else {
        currentts = NOW - _timestamp;
    }
    return currentts;
}

@end
