
### 概述
通过本文，您可以使用iOS版本的云上曲率实时语音翻译SDK，来实现实时语音场景下的翻译业务。

### SDK集成

#### 服务开通
云上曲率实时语音翻译SDK的使用，需要在云上曲率官网(https://www.ilivedata.com/) 注册账号并创建实时语音翻译服务项目。完成后，获取到项目对应的参数，更新到SDK中，再进行集成使用。

#### 版本支持

支持 iOS 12.0版本及以上。

#### 使用要求
 - 实时音频格式支持：只支持PCM格式音频
 - 采样率：16K Hz
 - 编码：16bit位深
 - 声道：单声道

#### 集成依赖
- 在 **TARGETS->Build Settings->Other Linker Flags** （选中 "**ALL**" 视图）中添加 "**-ObjC**"，字母 “**O**” 和 "**C**" 大写，符号 “**-**” 请勿忽略。
- 静态库中采用 **Objective-C++** 实现，因此需要您保证您工程中至少有一个 **.mm** 后缀的源文件(您可以将任意一个**.m**后缀的文件改名为**.mm**)。
- 添加库 **libresolv.9.tbd**。

#### 初始化
```objc {.line-numbers}
+ (nullable instancetype)clientWithEndpoint:(nonnull NSString * )endpoint
                                  projectId:(int64_t)projectId
                                   delegate:(id <RTVTProtocol>)delegate;
```
| 参数 | 类型 | 必需 | 说明 |
|:---:|:---:|:---:|---|
| endpoint | string | 必需 | 控制台提供的SDK接入地址  |
| projcetId | int64  | 必需 | 项目id  |
| delgate | - | - | 代理参考以下引入内容 |

##### 引入 **RTVTProtocol** 协议

```objc {.line-numbers}
/// 翻译最终结果
/// - Parameters:
///   - streamId: 翻译流id
///   - startTs: 识别对应语音开始时间
///   - endTs: 结束时间
///   - result: 翻译最终结果
///   - language: 目标语言
///   - recTs: 识别完成的服务器时间
-(void)translatedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                           language:(NSString * _Nullable)language
                              recTs:(int64_t)recTs;

/// 识别最终结果
/// - Parameters:
///   - streamId: 翻译流id
///   - startTs: 识别对应语音开始时间
///   - endTs: 结束时间
///   - result: 识别最终结果
///   - language: 目标语言
///   - recTs: 识别完成的服务器时间
-(void)recognizedResultWithStreamId:(int64_t)streamId
                            startTs:(int64_t)startTs
                              endTs:(int64_t)endTs
                             result:(NSString * _Nullable)result
                           language:(NSString * _Nullable)language
                              recTs:(int64_t)recTs;


/// 翻译临时结果
/// - Parameters:
///   - streamId: 翻译流id
///   - startTs: 识别对应语音开始时间
///   - endTs: 结束时间
///   - result: 翻译临时结果
///   - language: 目标语言
///   - recTs: 识别完成的服务器时间
-(void)translatedTmpResultWithStreamId:(int64_t)streamId
                               startTs:(int64_t)startTs
                                 endTs:(int64_t)endTs
                                result:(NSString * _Nullable)result
                              language:(NSString * _Nullable)language
                                 recTs:(int64_t)recTs;


/// 识别临时结果
/// - Parameters:
///   - streamId: 翻译流id
///   - startTs: 识别对应语音开始时间
///   - endTs: 结束时间
///   - result: 识别临时结果
///   - language: 目标语言
///   - recTs: 识别完成的服务器时间
-(void)recognizedTmpResultWithStreamId:(int64_t)streamId
                               startTs:(int64_t)startTs
                                 endTs:(int64_t)endTs
                                result:(NSString * _Nullable)result
                              language:(NSString * _Nullable)language
                                 recTs:(int64_t)recTs;
```

#### 登录

```objc {.line-numbers}
- (void)loginWithToken:(nonnull NSString *)token
                    ts:(int64_t)ts
               success:(RTVTLoginSuccessCallBack)loginSuccess
           connectFail:(RTVTLoginFailCallBack)loginFail;
```

| 参数 | 类型 | 必需 | 说明 |
|:---:|:---:|:---:|---|
| token | string | 必需 | 参考控制台基本信息中密钥内容计算生成token  |
| ts   | int64  | 必需 | 生成token对应的时间  |


#### 开始实时语音翻译
```objc {.line-numbers}
-(void)starStreamTranslateWithAsrResult:(BOOL)asrResult
                            transResult:(BOOL)transResult
                             tempResult:(BOOL)tempResult
                              ttsResult:(BOOL)ttsResult
                             ttsSpeaker:(NSString * _Nullable)ttsSpeaker
                                 userId:(NSString * _Nullable)userId
                            srcLanguage:(nonnull NSString *)srcLanguage
                           destLanguage:(nonnull NSString *)destLanguage
                         srcAltLanguage:(NSArray <NSString*> * _Nullable) srcAltLanguage
                              codecType:(RTVTAudioDataCodecType)codecType
                              attribute:(NSString * _Nullable)attribute
                                success:(void(^)(int64_t streamId))successCallback
                                   fail:(RTVTAnswerFailCallBack)failCallback;
```
| 参数 | 类型 | 必需 | 说明 |
|:---:|:---:|:---:|---|
| asrResult  | bool   | 必需 | 设置是否需要语音识别结果  |
| transResult   | bool  | 必需 | 设置是否需要翻译结果  |
| tempResult   | bool  | 必需 | 设置是否需要临时结果|
| ttsResult   | bool  | 必需 | 设置是否需要语音结果|
| ttsSpeaker   | string  | 可选 | 设置音色|
| userId  | string | 可选 | 用户id，业务侧可自行按需传入  |
| srcLanguage | string | 必需 | 源语言  |
| destLanguage | string  | 必需 | 目标语言，如果只需转写功能，目标语言可以可传空字符串  |
| srcAltLanguage   | array  | 可选 | 源语言的备选语言范围，最多支持3个语种传入  |
| codecType | int | 必需 | 上传数据的编码类型  |
| attribute | string | 可选 | 属性自定义  |
| callback   | -  | - | 成功后，服务端生成streamId并回调给SDK  |


```objc {.line-numbers}
-(void)multi_starTranslateWithAsrResult:(BOOL)asrResult
                             tempResult:(BOOL)tempResult
                                 userId:(NSString * _Nullable)userId
                            srcLanguage:(nonnull NSString *)srcLanguage
                         srcAltLanguage:(NSArray <NSString*> * _Nullable) srcAltLanguage
                                success:(void(^)(int64_t streamId))successCallback
                                   fail:(RTVTAnswerFailCallBack)failCallback;                                
```
| 参数 | 类型 | 必需 | 说明 |
|:---:|:---:|:---:|---|
| asrResult  | bool   | 必需 | 设置是否需要语音识别结果  |
| tempResult   | bool  | 必需 | 设置是否需要临时结果|
| userId  | string | 可选 | 用户id，业务侧可自行按需传入  |
| srcLanguage | string | 必需 | 源语言  |
| srcAltLanguage   | array  | 可选 | 源语言的备选语言范围，最多支持3个语种传入  |
| callback   | -  | - | 成功后，服务端生成streamId并回调给SDK  |



注意：<br>
1.需要回调识别结果的场景，需要将 "**asrResult**" 设置为 **true** ，"**srcLanguage**" 必传，"**srcAltLanguage**" 可选；<br>
2.需要翻译结果的场景，需要将 "**transResult**" 设置为 **true**，"**destLanguage**" 必传，且不能传空字符串；<br>
3.如果需要使用中间识别和翻译结果，那么需要手动将 "**tempResult**" 设置为 **true**；<br>
4.如果传入语种到 "**srcAltLanguage**" ，那么会默认先进行语种识别流程，开始的部分音频（3s左右）会用于语种识别流程，之后的识别/翻译结果会正常返回；<br>
5.如果传入的语种不在支持的语种范围内，会提示“**语种不支持**”；如果传入的语种在项目中未被启用，则会提示“**项目不支持**”。<br>



#### 发送语音片段
```objc {.line-numbers}
-(void)sendVoiceWithStreamId:(int64_t)streamId
                   voiceData:(nonnull NSData*)voiceData
                         seq:(int64_t)seq
                          ts:(int64_t)ts
                     success:(RTVTAnswerSuccessCallBack)successCallback
                        fail:(RTVTAnswerFailCallBack)failCallback;
```
| 参数 | 类型 |  必需 | 说明 |
|:---:|:---:|:---:|---|
| streamId | int64_t |  必需 | 语音流id  |
| seq | int64_t  |  必需 | 语音片段序号（尽量有序）  |
| voiceData   | byte |  必需 | 语音数据，默认640字节 |
| ts   | int64_t  |  必需 | 音频帧对应时间戳  |


```objc {.line-numbers}
-(void)multi_sendVoiceWithStreamId:(int64_t)streamId
                         voiceData:(nonnull NSData*)voiceData
                     destLanguages:(NSArray<NSString*>*)destLanguages
                               seq:(int64_t)seq
                                ts:(int64_t)ts
                           success:(RTVTAnswerSuccessCallBack)successCallback
                              fail:(RTVTAnswerFailCallBack)failCallback;
```
| 参数 | 类型 |  必需 | 说明 |
|:---:|:---:|:---:|---|
| streamId | int64_t |  必需 | 语音流id  |
| seq | int64_t  |  必需 | 语音片段序号（尽量有序）  |
| destLanguage | string  | 必需 | 目标语言  |
| voiceData   | byte |  必需 | 语音数据，默认640字节 |
| ts   | int64_t  |  必需 | 音频帧对应时间戳  |

#### 停止翻译
```objc {.line-numbers}
-(void)endTranslateWithStreamId:(int)streamId
                        lastSeq:(int)lastSeq
                        success:(RTVTAnswerSuccessCallBack)successCallback
                           fail:(RTVTAnswerFailCallBack)failCallback;

```
| 参数 | 类型 |  必需 | 说明 |
|:---:|:---:|:---:| ---|
| streamId | int |  必需 | 翻译的语音流id  |
| lastSeq   | int  |  必需 | 最后的语音片段  |

#### 结束
```objc {.line-numbers}
- (BOOL)closeConnect;
```
{{% notice info %}}注意，使用结束时调用。下次使用需要先登录。{{% /notice %}}

#### 错误码
| 错误码 |  说明 |
|:---:|:---:|
| 800000 | 未知错误  |
| 800002   | 未验证的链接  |
| 800003   | 无效参数  |
| 800101   | 无效的系统时间  |
| 800102   | token非法，无效编码  |
| 800103   | 无效的pid  |
| 800105   | 不支持的语言  |
| 800106   | 备选语言过多  |
| 800107   | 翻译流到达上限  |
| 800200   | 流id不存在  |

### SDK下载
SDK下载和更多说明请前往[Github](https://github.com/highras/rtvt-client-sdk-objc)。
