//
//  VoiceCapture.h
//  RTVT_Test
//
//  Created by 张世良 on 2022/11/16.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

#define RTVInputBus 1
#define RTVOutputBus 0
#define RTVSampleRate_16000 16000
#define RTVFrameNumber_16000   RTVSampleRate_16000/50

@interface VoiceCapture : NSObject

@property(nonatomic,strong)void (^pcmCall)(NSData* pcmData);
@property(nonatomic,assign)BOOL isRecodering;
@property(nonatomic,strong)NSMutableData * recoderData;
@property (nonatomic,assign) AudioComponentInstance recoderAudioUnit;
- (void)handleRecoderBuffer:(AudioBufferList* )audioBufferList;
-(void)startCapture;
-(void)endCapture;

@end

NS_ASSUME_NONNULL_END
