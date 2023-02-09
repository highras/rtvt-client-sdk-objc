//
//  GetToken.h
//  RTVT_Test
//
//  Created by 张世良 on 2023/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetToken : NSObject
+(NSDictionary*)getToken:(NSString*)key pid:(NSString*)pid;

@end

NS_ASSUME_NONNULL_END
