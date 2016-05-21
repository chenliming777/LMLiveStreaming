//
//  LMVideoStreamingConfiguration.m
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import "LMVideoStreamingConfiguration.h"
#import <AVFoundation/AVFoundation.h>

@interface LMVideoStreamingConfiguration ()

@property (nonatomic, assign,readwrite) CGSize  videoSize;

@end

@implementation LMVideoStreamingConfiguration

#pragma mark -- LifeCycle
+ (instancetype)defaultConfiguration{
    LMVideoStreamingConfiguration *configuration = [LMVideoStreamingConfiguration defaultConfigurationForQuality:LMStreamingVideoQuality_Default];
    return configuration;
}

+ (instancetype)defaultConfigurationForQuality:(LMStreamingVideoQuality)videoQuality{
    LMVideoStreamingConfiguration *configuration = [LMVideoStreamingConfiguration new];
    switch (videoQuality) {
        case LMStreamingVideoQuality_Low1:
        {
            configuration.sessionPreset = LMCaptureSessionPreset360x640;
            configuration.videoFrameRate = 15;
            configuration.videoBitRate = 500 * 1024;
        }
            break;
        case LMStreamingVideoQuality_Low2:
        {
            configuration.sessionPreset = LMCaptureSessionPreset360x640;
            configuration.videoFrameRate = 24;
            configuration.videoBitRate = 800 * 1024;
        }
            break;
        case LMStreamingVideoQuality_Low3:
        {
            configuration.sessionPreset = LMCaptureSessionPreset360x640;
            configuration.videoFrameRate = 30;
            configuration.videoBitRate = 800 * 1024;
        }
            break;
        case LMStreamingVideoQuality_Medium1:
        {
            configuration.sessionPreset = LMCaptureSessionPreset540x960;
            configuration.videoFrameRate = 15;
            configuration.videoBitRate = 800 * 1024;
        }
            break;
        case LMStreamingVideoQuality_Medium2:
        {
            configuration.sessionPreset = LMCaptureSessionPreset540x960;
            configuration.videoFrameRate = 24;
            configuration.videoBitRate = 1000 * 1024;
        }
            break;
        case LMStreamingVideoQuality_Medium3:
        {
            configuration.sessionPreset = LMCaptureSessionPreset540x960;
            configuration.videoFrameRate = 30;
            configuration.videoBitRate = 1000 * 1024;
        }
            break;
        case LMStreamingVideoQuality_High1:
        {
            configuration.sessionPreset = LMCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 15;
            configuration.videoBitRate = 1000 * 1024;
        }
            break;
        case LMStreamingVideoQuality_High2:
        {
            configuration.sessionPreset = LMCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 24;
            configuration.videoBitRate = 1200 * 1024;
        }
            break;
        case LMStreamingVideoQuality_High3:
        {
            configuration.sessionPreset = LMCaptureSessionPreset720x1280;
            configuration.videoFrameRate = 30;
            configuration.videoBitRate = 1200 * 1024;
        }
            break;
        default:
            break;
    }
    configuration.sessionPreset = [configuration supportSessionPreset:configuration.sessionPreset];
    configuration.videoMaxKeyframeInterval = configuration.videoFrameRate*2;
    configuration.videoSize = [configuration supportVideoSize:configuration.sessionPreset];
    return configuration;
}

#pragma mark -- Setter Getter
- (NSString*)avSessionPreset{
    NSString *avSessionPreset = nil;
    switch (self.sessionPreset) {
        case LMCaptureSessionPreset360x640:
        {
            avSessionPreset = AVCaptureSessionPreset640x480;
        }
            break;
        case LMCaptureSessionPreset540x960:
        {
            avSessionPreset = AVCaptureSessionPresetiFrame960x540;
        }
            break;
        case LMCaptureSessionPreset720x1280:
        {
            avSessionPreset = AVCaptureSessionPreset1280x720;
        }
            break;
        default:{
            avSessionPreset = AVCaptureSessionPreset640x480;
        }
            break;
    }
    return avSessionPreset;
}

- (NSUInteger)videoMaxFrameRate{
    return 24;
}

- (NSUInteger)videoMinFrameRate{
    return 12;
}

- (NSUInteger)videoMaxBitRate{
    return 1200*1024;
}

- (NSUInteger)videoMinBitRate{
    return 500*1024;
}

#pragma mark -- Custom Method
- (CGSize)supportVideoSize:(LMStreamingVideoSessionPreset)sessionPreset{
    CGSize result = CGSizeZero;
    switch (sessionPreset) {
        case LMCaptureSessionPreset360x640:
        {
            result = CGSizeMake(360, 640);
        }
            break;
        case LMCaptureSessionPreset540x960:
        {
            result = CGSizeMake(540, 960);
        }
            break;
        case LMCaptureSessionPreset720x1280:
        {
            result = CGSizeMake(720, 1280);
        }
            break;
    }
    return result;
}

- (LMStreamingVideoSessionPreset)supportSessionPreset:(LMStreamingVideoSessionPreset)sessionPreset{
    NSString *avSessionPreset = [self avSessionPreset];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if(![session canSetSessionPreset:avSessionPreset]){
        if(sessionPreset == LMCaptureSessionPreset720x1280){
            sessionPreset = LMCaptureSessionPreset540x960;
            if(![session canSetSessionPreset:avSessionPreset]){
                sessionPreset = LMCaptureSessionPreset360x640;
            }
        }
    }else{
        sessionPreset = LMCaptureSessionPreset360x640;
    }
    return sessionPreset;
}

- (BOOL)isClipVideo{
    return self.sessionPreset == LMCaptureSessionPreset360x640 ? YES : NO;
}

#pragma mark -- encoder
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSValue valueWithCGSize:self.videoSize] forKey:@"videoSize"];
    [aCoder encodeObject:@(self.videoFrameRate) forKey:@"videoFrameRate"];
    [aCoder encodeObject:@(self.videoMaxKeyframeInterval) forKey:@"videoMaxKeyframeInterval"];
    [aCoder encodeObject:@(self.videoBitRate) forKey:@"videoBitRate"];
    [aCoder encodeObject:@(self.sessionPreset) forKey:@"sessionPreset"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    _videoSize = [[aDecoder decodeObjectForKey:@"videoSize"] CGSizeValue];
    _videoFrameRate = [[aDecoder decodeObjectForKey:@"videoFrameRate"] unsignedIntegerValue];
    _videoMaxKeyframeInterval = [[aDecoder decodeObjectForKey:@"videoMaxKeyframeInterval"] unsignedIntegerValue];
    _videoBitRate = [[aDecoder decodeObjectForKey:@"videoBitRate"] unsignedIntegerValue];
    _sessionPreset = [[aDecoder decodeObjectForKey:@"sessionPreset"] unsignedIntegerValue];
    return self;
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    NSArray *values = @[[NSValue valueWithCGSize:self.videoSize],
                        @(self.videoFrameRate),
                        @(self.videoMaxFrameRate),
                        @(self.videoMinFrameRate),
                        @(self.videoMaxKeyframeInterval),
                        @(self.videoBitRate),
                        @(self.videoMaxBitRate),
                        @(self.videoMinBitRate),
                        @(self.isClipVideo),
                        self.avSessionPreset,
                        @(self.sessionPreset),];
    
    for (NSObject *value in values) {
        hash ^= value.hash;
    }
    return hash;
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else if (![super isEqual:other]) {
        return NO;
    } else {
        LMVideoStreamingConfiguration *object = other;
        return CGSizeEqualToSize(object.videoSize, self.videoSize)  &&
        object.videoFrameRate == self.videoFrameRate &&
        object.videoMaxFrameRate == self.videoMaxFrameRate &&
        object.videoMinFrameRate == self.videoMinFrameRate &&
        object.videoMaxKeyframeInterval == self.videoMaxKeyframeInterval &&
        object.videoBitRate == self.videoBitRate &&
        object.videoMaxBitRate == self.videoMaxBitRate &&
        object.videoMinBitRate == self.videoMinBitRate &&
        object.isClipVideo == self.isClipVideo &&
        [object.avSessionPreset isEqualToString:self.avSessionPreset] &&
        object.sessionPreset == self.sessionPreset;
    }
}

- (id)copyWithZone:(nullable NSZone *)zone{
    LMVideoStreamingConfiguration *other = [self.class defaultConfiguration];
    return other;
}

- (NSString *)description{
    NSMutableString *desc = @"".mutableCopy;
    [desc appendFormat:@"<LMVideoStreamingConfiguration: %p>",self];
    [desc appendFormat:@" videoSize:%@",NSStringFromCGSize(self.videoSize)];
    [desc appendFormat:@" videoFrameRate:%zi",self.videoFrameRate];
    [desc appendFormat:@" videoMaxFrameRate:%zi",self.videoMaxFrameRate];
    [desc appendFormat:@" videoMinFrameRate:%zi",self.videoMinFrameRate];
    [desc appendFormat:@" videoMaxKeyframeInterval:%zi",self.videoMaxKeyframeInterval];
    [desc appendFormat:@" videoBitRate:%zi",self.videoBitRate];
    [desc appendFormat:@" videoMaxBitRate:%zi",self.videoMaxBitRate];
    [desc appendFormat:@" videoMinBitRate:%zi",self.videoMinBitRate];
    [desc appendFormat:@" isClipVideo:%zi",self.isClipVideo];
    [desc appendFormat:@" avSessionPreset:%@",self.avSessionPreset];
    [desc appendFormat:@" sessionPreset:%zi",self.sessionPreset];
    return desc;
}

@end
