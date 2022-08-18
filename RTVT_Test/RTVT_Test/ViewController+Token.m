//
//  ViewController+Token.m
//  RTVT_Test
//
//  Created by zsl on 2022/8/15.
//

#import "ViewController+Token.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation ViewController (Token)
#pragma mark token
- (NSString *)md5:(NSString*)string {
    
    if(string == nil || [string length] == 0){
        return nil;
    }
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}
- (NSString *)hmacSHA256WithSecret:(NSString *)secret content:(NSString *)content{
    
    const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSMutableString *hexString = [NSMutableString string];
    for (int i=0; i<sizeof(cHMAC); i++){
        [hexString appendFormat:@"%02x", cHMAC[i]];
    }
    return hexString;
}

-(void)getToken{
    
    NSString * time = [NSString stringWithFormat:@"%@",[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]]];
//    NSString * coreString = [NSString stringWithFormat:@"%d:%@",9008000,time];
    NSString * coreString = [NSString stringWithFormat:@"%d:%@",90008000,time];
    NSString * md5String = [self md5:coreString].lowercaseString;
    NSString * h256String = [self hmacSHA256WithSecret:@"qwerty" content:md5String];
    
//    NSData *data = [h256String dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64String = [data base64EncodedStringWithOptions:0];
    
    self.authTime = [time longLongValue];
    self.authToken = h256String;
    
    NSLog(@"authToken = %@  authTime = %lld",self.authToken,self.authTime);
    
}
@end
