//
//  LMAudioStreamingConfiguration.h
//  LMLiveStreaming
//
//  Created by 倾慕 on 16/5/1.
//  Copyright © 2016年 倾慕. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 音频码率
typedef NS_ENUM(NSUInteger, LMStreamingAudioBitRate) {
    /// 32Kbps 音频码率
    LMStreamingAudioBitRate_32Kbps = 32000,
    /// 64Kbps 音频码率
    LMStreamingAudioBitRate_64Kbps = 64000,
    /// 96Kbps 音频码率
    LMStreamingAudioBitRate_96Kbps = 96000,
    /// 128Kbps 音频码率
    LMStreamingAudioBitRate_128Kbps = 128000,
    /// 默认音频码率，默认为 64Kbps
    LMStreamingAudioBitRate_Default = LMStreamingAudioBitRate_64Kbps
};

/// 采样率 (默认44.1Hz iphoneg6以上48Hz)
typedef NS_ENUM(NSUInteger, LMStreamingAudioSampleRate){
    /// 44.1Hz 采样率
    LMStreamingAudioSampleRate_44100Hz = 44100,
    /// 48Hz 采样率
    LMStreamingAudioSampleRate_48000Hz = 48000,
    /// 默认音频码率，默认为 64Kbps
    LMStreamingAudioSampleRate_Default = LMStreamingAudioSampleRate_44100Hz
};

///  Audio streaming quality（音频质量）
typedef NS_ENUM(NSUInteger, LMStreamingAudioQuality){
    /// 高音频质量 audio sample rate: 44MHz(默认44.1Hz iphoneg6以上48Hz), audio bitrate: 32Kbps
    LMStreamingAudioQuality_Low = 0,
    /// 高音频质量 audio sample rate: 44MHz(默认44.1Hz iphoneg6以上48Hz), audio bitrate: 64Kbps
    LMStreamingAudioQuality_Medium = 1,
    /// 高音频质量 audio sample rate: 44MHz(默认44.1Hz iphoneg6以上48Hz), audio bitrate: 96Kbps
    LMStreamingAudioQuality_High = 2,
    /// 高音频质量 audio sample rate: 44MHz(默认44.1Hz iphoneg6以上48Hz), audio bitrate: 128Kbps
    LMStreamingAudioQuality_VeryHigh = 3,
    /// 默认音频质量 audio sample rate: 44MHz(默认44.1Hz iphoneg6以上48Hz), audio bitrate: 64Kbps
    LMStreamingAudioQuality_Default = LMStreamingAudioQuality_Medium
};

@interface LMAudioStreamingConfiguration : NSObject<NSCoding,NSCopying>

/// 默认音频配置
+ (instancetype)defaultConfiguration;
/// 音频配置
+ (instancetype)defaultConfigurationForQuality:(LMStreamingAudioQuality)audioQuality;

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/// 声道数目(default 2)
@property (nonatomic, assign) NSUInteger numberOfChannels;
/// 采样率
@property (nonatomic, assign) LMStreamingAudioSampleRate audioSampleRate;
// 码率
@property (nonatomic, assign) LMStreamingAudioBitRate audioBitrate;
/// flv编码音频头 44100 为0x12 0x10
@property (nonatomic ,assign,readonly) char *asc;

@end
