//
//  WFAVEngineKit.h
//  WFAVEngineKit
//
//  Created by heavyrain on 17/9/27.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for WFAVEngineKit.
FOUNDATION_EXPORT double WFAVEngineKitVersionNumber;

//! Project version string for WFAVEngineKit.
FOUNDATION_EXPORT const unsigned char WFAVEngineKitVersionString[];

#import <Foundation/Foundation.h>
#import <WebRTC/WebRTC.h>
#import <WFChatClient/WFCChatClient.h>

@class WFAVCallSession;

#pragma mark - 枚举值定义
/**
 通话状态

 - kWFAVEngineStateIdle: 无通话状态
 - kWFAVEngineStateOutgoing: 呼出中
 - kWFAVEngineStateIncomming: 呼入中
 - kWFAVEngineStateConnecting: 建立中
 - kWFAVEngineStateConnected: 通话中
 */
typedef NS_ENUM(NSInteger, WFAVEngineState) {
  kWFAVEngineStateIdle,
  kWFAVEngineStateOutgoing,
  kWFAVEngineStateIncomming,
  kWFAVEngineStateConnecting,
  kWFAVEngineStateConnected
};

/**
 缩放模式

 - kWFAVVideoScalingTypeAspectFit: 自适应
 - kWFAVVideoScalingTypeAspectFill: 拉伸
 - kWFAVVideoScalingTypeAspectBalanced: 平衡
 */
typedef NS_ENUM(NSInteger, WFAVVideoScalingType) {
    kWFAVVideoScalingTypeAspectFit,
    kWFAVVideoScalingTypeAspectFill,
    kWFAVVideoScalingTypeAspectBalanced
};

/**
 视频属性
 分辨率(宽x高), 帧率(fps),码率(kpbs)

 - kWFAVVideoProfile120P:       160x120,    15, 120
 - kWFAVVideoProfile120P_3:     120x120,    15, 100
 - kWFAVVideoProfile180P:       320x180,    15, 280
 - kWFAVVideoProfile180P_3:     180x180,    15, 200
 - kWFAVVideoProfile180P_4:     240x180,    15, 240
 - kWFAVVideoProfile240P:       320x240,    15, 360
 - kWFAVVideoProfile240P_3:     240x240,    15, 280
 - kWFAVVideoProfile240P_4:     424x240,    15, 400
 - kWFAVVideoProfile360P:       640x360,    15, 800
 - kWFAVVideoProfile360P_3:     360x360,    15, 520
 - kWFAVVideoProfile360P_4:     640x360,    30, 1200
 - kWFAVVideoProfile360P_6:     360x360,    30, 780
 - kWFAVVideoProfile360P_7:     480x360,    15, 1000
 - kWFAVVideoProfile360P_8:     480x360,    30, 1500
 - kWFAVVideoProfile480P:       640x480,    15, 1000
 - kWFAVVideoProfile480P_3:     480x480,    15, 800
 - kWFAVVideoProfile480P_4:     640x480,    30, 1500
 - kWFAVVideoProfile480P_6:     480x480,    30, 1200
 - kWFAVVideoProfile480P_8:     848x480,    15, 1200
 - kWFAVVideoProfile480P_9:     848x480,    30, 1800
 - kWFAVVideoProfile720P:       1280x720,   15, 2400
 - kWFAVVideoProfile720P_3:     1280x720,   30, 3699
 - kWFAVVideoProfile720P_5:     960x720,    15, 1920
 - kWFAVVideoProfile720P_6:     960x720,    30, 2880
 - kWFAVVideoProfileDefault:    默认值kWFAVVideoProfile360P
 */
typedef NS_ENUM(NSInteger, WFAVVideoProfile) {
    kWFAVVideoProfile120P       = 0,
    kWFAVVideoProfile120P_3     = 2,
    kWFAVVideoProfile180P       = 10,
    kWFAVVideoProfile180P_3     = 12,
    kWFAVVideoProfile180P_4     = 13,
    kWFAVVideoProfile240P       = 20,
    kWFAVVideoProfile240P_3     = 22,
    kWFAVVideoProfile240P_4     = 23,
    kWFAVVideoProfile360P       = 30,
    kWFAVVideoProfile360P_3     = 32,
    kWFAVVideoProfile360P_4     = 33,
    kWFAVVideoProfile360P_6     = 35,
    kWFAVVideoProfile360P_7     = 36,
    kWFAVVideoProfile360P_8     = 37,
    kWFAVVideoProfile480P       = 40,
    kWFAVVideoProfile480P_3     = 42,
    kWFAVVideoProfile480P_4     = 43,
    kWFAVVideoProfile480P_6     = 45,
    kWFAVVideoProfile480P_8     = 47,
    kWFAVVideoProfile480P_9     = 48,
    kWFAVVideoProfile720P       = 50,
    kWFAVVideoProfile720P_3     = 52,
    kWFAVVideoProfile720P_5     = 54,
    kWFAVVideoProfile720P_6     = 55,
    kWFAVVideoProfileDefault    = kWFAVVideoProfile360P
};

/**
 通话结束原因
 - kWFAVCallEndReasonUnknown: 未知错误
 - kWFAVCallEndReasonBusy: 忙线
 - kWFAVCallEndReasonSignalError: 链路错误
 - kWFAVCallEndReasonHangup: 用户挂断
 - kWFAVCallEndReasonMediaError: 媒体错误
 - kWFAVCallEndReasonRemoteHangup: 对方挂断
 - kWFAVCallEndReasonOpenCameraFailure: 摄像头错误
 - kWFAVCallEndReasonTimeout: 未接听
 - kWFAVCallEndReasonAcceptByOtherClient: 被其它端接听
 */
typedef NS_ENUM(NSInteger, WFAVCallEndReason) {
  kWFAVCallEndReasonUnknown = 0,
  kWFAVCallEndReasonBusy,
  kWFAVCallEndReasonSignalError,
  kWFAVCallEndReasonHangup,
  kWFAVCallEndReasonMediaError,
  kWFAVCallEndReasonRemoteHangup,
  kWFAVCallEndReasonOpenCameraFailure,
  kWFAVCallEndReasonTimeout,
  kWFAVCallEndReasonAcceptByOtherClient
};

#pragma mark - 通话监听
/**
 全局的通话事件监听
 */
@protocol WFAVEngineDelegate <NSObject>

/**
 收到通话的回调

 @param session 通话Session
 */
- (void)didReceiveCall:(WFAVCallSession *)session;

/**
 播放铃声的回调

 @param isIncoming 来电或去电
 */
- (void)shouldStartRing:(BOOL)isIncoming;

/**
 停止播放铃声的回调
 */
- (void)shouldStopRing;

@end

/**
 每次通话Session的事件监听
 */
@protocol WFAVCallSessionDelegate <NSObject>

/**
 通话状态变更的回调
 
 @param state 通话状态
 */
- (void)didChangeState:(WFAVEngineState)state;

/**
 通话结束的回调

 @param reason 通话结束的原因
 */
- (void)didCallEndWithReason:(WFAVCallEndReason)reason;

/**
 通话发生错误的回调

 @param error 错误
 */
- (void)didError:(NSError *)error;

/**
 通话模式发生变化的回调
 
 @param isAudioOnly 是否是纯语音
 */
- (void)didChangeMode:(BOOL)isAudioOnly;

/**
 通话状态统计的回调

 @param stats 统计信息
 */
- (void)didGetStats:(NSArray *)stats;

/**
 创建本地视频流的回调

 @param localVideoTrack 本地视频流
 */
- (void)didCreateLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

/**
 收到对方视频流的回调

 @param remoteVideoTrack 对方视频流
 */
- (void)didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

@end

#pragma mark - 通话引擎

/**
 通话引擎
 */
@interface WFAVEngineKit : NSObject

/**
 单例

 @return 通话引擎的单例
 */
+ (instancetype)sharedEngineKit;

/**
 添加ICE服务地址和鉴权

 @param address 服务地址
 @param userName 用户名
 @param password 密码
 */
- (void)addIceServer:(NSString *)address
            userName:(NSString *)userName
            password:(NSString *)password;

/**
 是否启用统计功能
 */
@property(nonatomic, assign) BOOL shouldGetStats;

/**
 全局的通话事件监听
 */
@property(nonatomic, weak) id<WFAVEngineDelegate> delegate;

/**
 当前的通话Session
 */
@property(nonatomic, strong, readonly) WFAVCallSession *currentSession;

/**
 发起通话

 @param clientId 对方用户ID
 @param conversation 通话所在会话
 @param sessionDelegate 通话Session的监听
 @return 通话Session
 */
- (WFAVCallSession *)startCall:(NSString *)clientId
                     audioOnly:(BOOL)audioOnly
                  conversation:(WFCCConversation *)conversation
               sessionDelegate:(id<WFAVCallSessionDelegate>)sessionDelegate;

/**
 开启画面预览
 */
- (void)startPreview;

/**
 设置视频参数

 @param videoProfile 视频属性
 @param swapWidthHeight 是否旋转
 */
- (void)setVideoProfile:(WFAVVideoProfile)videoProfile swapWidthHeight:(BOOL)swapWidthHeight;


/*!
 模态弹出ViewController，是个工具方法。这里用来弹出通话界面，也可以弹出别的界面，但注意要配对这里的dismiss来关闭界面。弹出通话界面你也可以自己来处理，不一定必须使用此工具方法。
 */
- (void)presentViewController:(UIViewController *)viewController;

/*!
 取消通话界面
 */
- (void)dismissViewController:(UIViewController *)viewController;
@end

#pragma mark - 通话Session
/**
 通话的Session实体
 */
@interface WFAVCallSession : NSObject

/**
 通话的唯一值
 */
@property(nonatomic, strong, readonly) NSString *callId;

/**
 对方的用户ID
 */
@property(nonatomic, strong, readonly) NSString *clientId;

/**
 通话Session的事件监听
 */
@property(nonatomic, weak)id<WFAVCallSessionDelegate> delegate;

/**
 通话状态
 */
@property(nonatomic, assign, readonly) WFAVEngineState state;

/**
 通话的开始时间，unix时间戳，单位为ms
 */
@property(nonatomic, assign, readonly) long long startTime;

/**
 通话的持续时间，unix时间戳，单位为ms
 */
@property(nonatomic, assign, readonly) long long connectedTime;

/**
 通话的结束时间，unix时间戳，单位为ms
 */
@property(nonatomic, assign, readonly) long long endTime;

/**
 通话所在的会话
 */
@property(nonatomic, strong, readonly) WFCCConversation *conversation;

/**
 是否是语音电话
 */
@property(nonatomic, assign, getter=isAudioOnly) BOOL audioOnly;

/**
 通话结束原因
 */
@property(nonatomic, assign, readonly)WFAVCallEndReason endReason;

/**
 是否是语音电话
 */
@property(nonatomic, assign, getter=isSpeaker, readonly)BOOL speaker;

/**
 接听通话
 */
- (void)answerCall:(BOOL)audioOnly;

/**
 挂断通话
 */
- (void)endCall;

/**
 开启或关闭声音

 @param muted 是否关闭
 @return 操作是否成功
 */
- (BOOL)muteAudio:(BOOL)muted;

/**
 开启或关闭扬声器
 
 @param speaker 是否使用扬声器
 @return 操作是否成功
 */
- (BOOL)enableSpeaker:(BOOL)speaker;

/**
 开启或关闭摄像头

 @param muted 是否关闭
 @return 操作是否成功
 */
- (BOOL)muteVideo:(BOOL)muted;

/**
 切换前后摄像头
 */
- (void)switchCamera;

/**
 设置本地视频视图Container
 
 @param videoContainerView 本地视频视图Container
 @param scalingType 缩放模式
 */
- (void)setupLocalVideoView:(UIView *)videoContainerView scalingType:(WFAVVideoScalingType)scalingType;

/**
 设置对端视频视图Container
 
 @param videoContainerView 本地视频视图Container
 @param scalingType 缩放模式
 */
- (void)setupRemoteVideoView:(UIView *)videoContainerView scalingType:(WFAVVideoScalingType)scalingType;
@end

