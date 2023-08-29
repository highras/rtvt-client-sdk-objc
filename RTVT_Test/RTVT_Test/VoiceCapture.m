//
//  VoiceCapture.m
//  RTVT_Test
//
//  Created by 张世良 on 2022/11/16.
//

#import "VoiceCapture.h"


static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    //16000:371    48000:1024
//    NSLog(@"设备录音 -- %u",(unsigned int)inNumberFrames);
    @autoreleasepool {
        
//        NSLog(@"%f",[[NSDate date] timeIntervalSince1970] * 1000);
        VoiceCapture *audioProcessor = (__bridge VoiceCapture* )inRefCon;
        if (audioProcessor.isRecodering) {
            AudioBuffer buffer;
            OSStatus status;
            buffer.mDataByteSize = inNumberFrames * sizeof(short) * 1;
            buffer.mNumberChannels = 1;
            buffer.mData = malloc(inNumberFrames * sizeof(short) * 1);
            AudioBufferList bufferList;
            bufferList.mNumberBuffers = 1;
            bufferList.mBuffers[0] = buffer;
            
            status = AudioUnitRender(audioProcessor.recoderAudioUnit,
                                     ioActionFlags,
                                     inTimeStamp,
                                     inBusNumber,
                                     inNumberFrames,
                                     &bufferList);
            
            [audioProcessor handleRecoderBuffer: &bufferList];
            free(bufferList.mBuffers[0].mData);
        }
        
    }
    
    return noErr;

}

@implementation VoiceCapture

-(instancetype)init{
    self = [super init];
    if (self) {
        
        self.recoderData = [NSMutableData data];
        [self _configBaseAudioConfig];
       
        
    }
    return self;
}

-(void)_configBaseAudioConfig{
    //录音---------------
    NSString * errorLog;
    
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    //kAudioUnitSubType_RemoteIO
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    status = AudioComponentInstanceNew(inputComponent, &_recoderAudioUnit);
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
    
    UInt32 flagIn = 1;
    status = AudioUnitSetProperty(self.recoderAudioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  RTVInputBus,
                                  &flagIn,
                                  sizeof(flagIn));
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
   
    //录音输出设定
    AudioStreamBasicDescription recoderAudioFormat;//13793
    recoderAudioFormat.mSampleRate    = RTVSampleRate_16000;
    recoderAudioFormat.mFormatID    = kAudioFormatLinearPCM;
    recoderAudioFormat.mFormatFlags    = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    recoderAudioFormat.mFramesPerPacket    = 1;
    recoderAudioFormat.mChannelsPerFrame    = 1;
    recoderAudioFormat.mBitsPerChannel    = 16;
    recoderAudioFormat.mBytesPerPacket    = 2 * 1;
    recoderAudioFormat.mBytesPerFrame    = 2 * 1;
    recoderAudioFormat.mReserved = 0;
    status = AudioUnitSetProperty(self.recoderAudioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  RTVInputBus,
                                  &recoderAudioFormat,
                                  sizeof(recoderAudioFormat));
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
    UInt32 playFlag = 0;
    status = AudioUnitSetProperty(self.recoderAudioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Output,
                         RTVOutputBus,
                         &playFlag,
                         sizeof(playFlag));
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
    
    //录音回调
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(self.recoderAudioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  RTVInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
    //开启录音降噪
    UInt32 echoCancellation;
    status = AudioUnitSetProperty(self.recoderAudioUnit,
                         kAUVoiceIOProperty_BypassVoiceProcessing,
                         kAudioUnitScope_Global,
                         1,
                         &echoCancellation,
                         sizeof(echoCancellation));
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
    status = AudioUnitInitialize(self.recoderAudioUnit);
    errorLog = [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
    
}
    
- (void)handleRecoderBuffer:(AudioBufferList* )audioBufferList {
    
    @synchronized (self) {
        
        @autoreleasepool {
            AudioBuffer sourceBuffer = audioBufferList -> mBuffers[0];
            NSData *pcmBlock = [NSData dataWithBytes:sourceBuffer.mData length:sourceBuffer.mDataByteSize];
            
            if (pcmBlock) {
                
                [self.recoderData appendData:pcmBlock];
                if (self.pcmCall != nil && self.recoderData.length >= RTVFrameNumber_16000 * sizeof(short) * 1) {
                    
                    NSData * perFramePcmData = [self.recoderData subdataWithRange:NSMakeRange(0, RTVFrameNumber_16000 * sizeof(short) * 1)];
                    [self.recoderData replaceBytesInRange:NSMakeRange(0, RTVFrameNumber_16000 * sizeof(short) * 1) withBytes:NULL length:0];
                    
//                    NSLog(@"%lu",(unsigned long)perFramePcmData.length);
                    self.pcmCall(perFramePcmData);
                    
                }
                
                if (self.pcmCall != nil && self.recoderData.length >= RTVFrameNumber_16000 * sizeof(short) * 1) {
                    
                    NSData * perFramePcmData = [self.recoderData subdataWithRange:NSMakeRange(0, RTVFrameNumber_16000 * sizeof(short) * 1)];
                    [self.recoderData replaceBytesInRange:NSMakeRange(0, RTVFrameNumber_16000 * sizeof(short) * 1) withBytes:NULL length:0];
                    
//                    NSLog(@"%lu",(unsigned long)perFramePcmData.length);
                    self.pcmCall(perFramePcmData);
                    
                }
            }
  
        }
    }
}

+ (NSString*)hasError:(int)statusCode file:(char*)file line:(int)line{
    if (statusCode){
        NSLog(@"Error Code responded %d in file %s on line %d", statusCode, file, line);
        return [NSString stringWithFormat:@"RTVAudioEngine Error Code responded %d in file %s on line %d", statusCode, file, line];
    }else{
        return nil;
    }
}
-(void)startCapture{
    
//    @synchronized (self) {
        
        if (self.isRecodering == NO) {
            self.isRecodering = YES;
            
            AudioOutputUnitStop(self.recoderAudioUnit);
            
            OSStatus status = AudioOutputUnitStart(self.recoderAudioUnit);
            
            [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
            
        }
//    }
    
}
-(void)endCapture{
    
//    @synchronized (self) {
        if (self.isRecodering == YES) {
            self.isRecodering = NO;
            self.recoderData = [NSMutableData data];
            OSStatus status = AudioOutputUnitStop(self.recoderAudioUnit);
            [VoiceCapture hasError:status file:__FILE__ line:__LINE__];
        }
//    }
    
}
@end
