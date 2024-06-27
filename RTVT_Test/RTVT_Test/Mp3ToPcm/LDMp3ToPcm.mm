//
//  LDMp3ToPcm.m
//  RTVT_Test
//
//  Created by Admin on 6/25/24.
//

#import "LDMp3ToPcm.h"

#define MINIMP3_FLOAT_OUTPUT
#include <thread>
#include <memory>
#include "samplerate.h"
#include "minimp3.h"
#include "minimp3_ex.h"
using namespace std;
@implementation LDMp3ToPcm
void Stereo2Mono_(const int16_t* src_audio,int frames,int16_t* dst_audio){
    for (int i = 0; i < frames; i++) {
        //注意 >>1 只有在有符号整形的情况下才代表除以2
        dst_audio[i] = ((int)src_audio[2 * i] + src_audio[2 * i + 1]) >> 1;
    }
}

//void Mono2Stereo(const int16_t* src_audio,int frames,int16_t* dst_audio){
//    for (int i = 0; i < frames; i++) {
//        dst_audio[2 * i] = src_audio[i];
//        dst_audio[2 * i + 1] = src_audio[i];
//
//    }
//}

+(NSData*)getPcmData:(NSString*)mp3Path sampleRate:(int)sampleRate{



    if (sampleRate != 16000 && sampleRate != 48000) {
        return nil;
    }
            
    NSString * path = mp3Path;
    std::string filePath = std::string([path UTF8String]);
//            int sampleRate = 16000;

    mp3dec_ex_t dec ;
    int err = mp3dec_ex_open(&dec, [path UTF8String], MP3D_SEEK_TO_SAMPLE | MP3D_ALLOW_MONO_STEREO_TRANSITION);
    if (err != 0){
        NSLog(@"getPcmData mp3dec open file error");
        mp3dec_ex_close(&dec);
        return nil;
    }

    int srcChannels =  dec.info.channels;
    int srchz =  dec.info.hz;
    int64_t samples = dec.samples;
    mp3d_sample_t *bgmtmpBuffer = new mp3d_sample_t[samples];
    int16_t * out;
    size_t readed1 = mp3dec_ex_read(&dec, bgmtmpBuffer, samples);
    if (readed1 != samples)
    {
        if (dec.last_error) {
            NSLog(@"getPcmData mp3dec if (dec.last_error) ");
            mp3dec_ex_close(&dec);
            return nil;
        }
    }
    mp3dec_ex_close(&dec);


//        NSLog(@" 声道%d  采样率%d  采样点数%lld",srcChannels,srchz,samples);
    int16_t *bgmBuffer = nullptr;
    int bgmBufferSize = 0;
    if (srchz != sampleRate) {
        SRC_STATE *resampler = src_new(SRC_LINEAR, srcChannels, &err);
        if (err != 0) {

            return nil;
        }
        SRC_DATA srcData;
        srcData.data_in = bgmtmpBuffer;
        srcData.input_frames = samples / srcChannels;
        samples = samples * sampleRate / srchz;
        shared_ptr<float> resampleData = shared_ptr<float>(new float[samples]);
        srcData.output_frames = samples / srcChannels;
        srcData.data_out = (float *) resampleData.get();
        srcData.end_of_input = 0;
        srcData.src_ratio = (double) sampleRate / srchz;

        err = src_process(resampler, &srcData);
        if (err != 0) {

            return nil;
        }
        src_delete(resampler);
        out = new int16_t[samples];
        mp3dec_f32_to_s16(resampleData.get(), out, samples);
    } else{
        out = new int16_t[samples];
        mp3dec_f32_to_s16(bgmtmpBuffer, out, samples);
    }


    if (bgmBuffer != nullptr) {
        delete[] bgmBuffer;
        bgmBuffer = nullptr;
    }

    if (srcChannels != 1) {
        bgmBuffer = new int16_t[samples / srcChannels];
        Stereo2Mono_(out, samples / srcChannels, bgmBuffer);
    } else {
        bgmBuffer = new int16_t[samples];
        memcpy(bgmBuffer, out, samples * sizeof(int16_t));
    }

    bgmBufferSize = samples/srcChannels;



    if(out != nullptr){
        delete out;
        out = nullptr;
    }
    if(bgmtmpBuffer != nullptr){
        delete[] bgmtmpBuffer;
        bgmtmpBuffer = nullptr;
    }
    NSData * result;
    if(bgmBuffer != nullptr){

        result = [NSData dataWithBytes:bgmBuffer length:bgmBufferSize * 2];
        delete bgmBuffer;
        bgmBuffer = nullptr;
    }



    return result;


    
}
@end
