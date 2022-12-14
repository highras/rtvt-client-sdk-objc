RTVT 使用文档
================================

* [版本支持](#版本支持)
* [集成依赖](#集成依赖)
* [登录](#登录)
* [代理方法](#代理方法)
* [使用接口](#使用接口)

<a id="版本支持">版本支持</a>
================
* 语言:Objective-C  
* 最低支持 iOS 10 系统



<a id="集成依赖">集成依赖</a>
================
* 在TARGETS->Build Settings->Other Linker Flags （选中ALL视图）中添加-ObjC，字母O和C大写，符号“-”请勿忽略
* 静态库中采用Objective-C++实现，因此需要您保证您工程中至少有一个.mm后缀的源文件(您可以将任意一个.m后缀的文件改名为.mm)
* 添加库libresolv.9.tbd


<a id="登录">登录</a>
================ 
```objc

+ (nullable instancetype)clientWithEndpoint:(nonnull NSString * )endpoint
                                  projectId:(int64_t)projectId
                                     userId:(int64_t)userId
                                   delegate:(id <RTVTProtocol>)delegate;


- (void)loginWithKey:(nonnull NSString *)key
             success:(RTVTLoginSuccessCallBack)loginSuccess
         connectFail:(RTVTLoginFailCallBack)loginFail;
```

<a id="代理方法">代理方法</a>
================

* 引入协议 RTVTProtocol    
```objc

@protocol RTVTProtocol 

@required
-(void)translatedResultWithStreamId:(int)streamId
                            startTs:(int)startTs
                              endTs:(int)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int)recTs;




@optional
-(void)recognizedResultWithStreamId:(int)streamId
                            startTs:(int)startTs
                              endTs:(int)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int)recTs;

//重连只有在登录成功过1次后才会有效
//重连将要开始  根据返回值是否进行重连
-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount;
//重连结果
-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error;
//关闭连接  
-(void)rtvtConnectClose:(RTVTClient *)client;
```






<a id="使用接口">使用接口</a>
================
```objc
/// 开始翻译 获取streamId
/// @param asrResult 是否需要语音识别的结果。 如果asrResult设置为NO 那么只会推送翻译语言的文本 如果asrResult设置为YES 那么会推送源语言和翻译语言两个结果翻
/// @param srcLanguage 源语言
/// @param destLanguage 目标语言
/// @param successCallback 成功回调
/// @param failCallback 失败回调
-(void)starStreamTranslateWithAsrResult:(BOOL)asrResult
                            srcLanguage:(nonnull NSString *)srcLanguage
                           destLanguage:(nonnull NSString *)destLanguage
                                success:(void(^)(int streamId))successCallback
                                   fail:(RTVTAnswerFailCallBack)failCallback;

/// 结束翻译 对应streamId
/// @param streamId 翻译流id
/// @param lastSeq seq
/// @param successCallback 成功回调
/// @param failCallback 失败回调
-(void)endTranslateWithStreamId:(int)streamId
                        lastSeq:(int)lastSeq
                        success:(RTVTAnswerSuccessCallBack)successCallback
                           fail:(RTVTAnswerFailCallBack)failCallback;


/// 发送音频数据  要求 : pcm 16k 16bit 单声道 每次640byte 20ms
/// @param streamId 流id
/// @param voiceData 音频数据
/// @param seq 自增seq 必传
/// @param ts 音频帧对应时间戳  毫秒 必传
/// @param successCallback 成功回调
/// @param failCallback 失败回调
-(void)sendVoiceWithStreamId:(int)streamId
                   voiceData:(nonnull NSData*)voiceData
                         seq:(int)seq
                          ts:(int)ts
                     success:(RTVTAnswerSuccessCallBack)successCallback
                        fail:(RTVTAnswerFailCallBack)failCallback;


//使用结束时调用 下次使用需要先登录
- (BOOL)closeConnect;
```



