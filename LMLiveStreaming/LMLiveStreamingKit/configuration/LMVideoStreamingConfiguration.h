//
//  LMVideoStreamingConfiguration.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 视频分辨率(都是16：9 当此设备不支持当前分辨率，自动降低一级)
typedef NS_ENUM(NSUInteger, LMStreamingVideoSessionPreset){
    /// 低分辨率
    LMCaptureSessionPreset360x640 = 0,
    /// 中分辨率
    LMCaptureSessionPreset540x960 = 1,
    /// 高分辨率
    LMCaptureSessionPreset720x1280 = 2
};

/// 视频质量
typedef NS_ENUM(NSUInteger, LMStreamingVideoQuality){
    /// 分辨率： 360 *640 帧数：15 码率：500Kps
    LMStreamingVideoQuality_Low1 = 0,
    /// 分辨率： 360 *640 帧数：24 码率：800Kps
    LMStreamingVideoQuality_Low2 = 1,
    /// 分辨率： 360 *640 帧数：30 码率：800Kps
    LMStreamingVideoQuality_Low3 = 2,
    /// 分辨率： 540 *960 帧数：15 码率：800Kps
    LMStreamingVideoQuality_Medium1 = 3,
    /// 分辨率： 540 *960 帧数：24 码率：1000Kps
    LMStreamingVideoQuality_Medium2 = 4,
    /// 分辨率： 540 *960 帧数：30 码率：1000Kps
    LMStreamingVideoQuality_Medium3 = 5,
    /// 分辨率： 720 *1280 帧数：15 码率：1000Kps
    LMStreamingVideoQuality_High1 = 6,
    /// 分辨率： 720 *1280 帧数：24 码率：1200Kps
    LMStreamingVideoQuality_High2 = 7,
    /// 分辨率： 720 *1280 帧数：30 码率：1200Kps
    LMStreamingVideoQuality_High3 = 8,
    /// 默认配置
    LMStreamingVideoQuality_Default = LMStreamingVideoQuality_Low2
};

@interface LMVideoStreamingConfiguration : NSObject<NSCoding,NSCopying>

/// 默认视频配置
+ (instancetype)defaultConfiguration;
/// 视频配置
+ (instancetype)defaultConfigurationForQuality:(LMStreamingVideoQuality)videoQuality;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// 视频的分辨率，宽高务必设定为 2 的倍数，否则解码播放时可能出现绿边
@property (nonatomic, assign,readonly) CGSize  videoSize;

/// 视频的帧率，即 fps
@property (nonatomic, assign) NSUInteger videoFrameRate;

/// 视频的最大帧率，即 fps
@property (nonatomic, assign,readonly) NSUInteger videoMaxFrameRate;

/// 视频的最小帧率，即 fps
@property (nonatomic, assign,readonly) NSUInteger videoMinFrameRate;

/// 最大关键帧间隔，可设定为 fps 的2倍，影响一个 gop 的大小
@property (nonatomic, assign) NSUInteger videoMaxKeyframeInterval;

/// 视频的码率，单位是 bps
@property (nonatomic, assign) NSUInteger videoBitRate;

/// 视频的最大码率，单位是 bps
@property (nonatomic, assign,readonly) NSUInteger videoMaxBitRate;

/// 视频的最小码率，单位是 bps
@property (nonatomic, assign,readonly) NSUInteger videoMinBitRate;

///< 分辨率
@property (nonatomic, assign) LMStreamingVideoSessionPreset sessionPreset;

///< ≈sde3分辨率
@property (nonatomic, assign,readonly) NSString *avSessionPreset;

///< 是否裁剪
@property (nonatomic, assign,readonly) BOOL isClipVideo;

@end
