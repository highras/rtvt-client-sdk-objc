//
//  LDMp3ToPcm.h
//  RTVT_Test
//
//  Created by Admin on 6/25/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LDMp3ToPcm : NSObject
+(NSData*)getPcmData:(NSString*)mp3Path sampleRate:(int)sampleRate;
@end

NS_ASSUME_NONNULL_END
