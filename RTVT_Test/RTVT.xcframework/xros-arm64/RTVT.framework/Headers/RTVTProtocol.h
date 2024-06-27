



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RTVTClient,RTVTAnswer,FPNError,RTVTMessage;
@protocol RTVTProtocol <NSObject>

@required

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
                              recTs:(int64_t)recTs
                             taskId:(int64_t)taskId;

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
                              recTs:(int64_t)recTs
                             taskId:(int64_t)taskId;


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
                                 recTs:(int64_t)recTs
                                taskId:(int64_t)taskId;


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
                                 recTs:(int64_t)recTs
                                taskId:(int64_t)taskId;



/// 语音翻译
/// - Parameters:
///   - streamId: 翻译流id
///   - text: 翻译结果
///   - data: 结果音频数据 mp3 单声道 16000hz
///   - language: 目标语言
-(void)ttsResultWithStreamId:(int64_t)streamId
                        text:(NSString * _Nullable)text
                        data:(NSData*)data
                    language:(NSString * _Nullable)language;




//重连只有在登录成功过1次后才会有效
//重连将要开始  根据返回值是否进行重连
-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount;
//重连结果
-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error;
//关闭连接  
-(void)rtvtConnectClose:(RTVTClient *)client;


@end

NS_ASSUME_NONNULL_END

