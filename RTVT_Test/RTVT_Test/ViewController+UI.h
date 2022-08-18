//
//  ViewController+UI.h
//  RTVT_Test
//
//  Created by zsl on 2022/8/15.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController (UI)

-(void)setUpUI;
-(void)showHudMessage:(NSString*)message hideTime:(int)hideTime;
-(void)showLoadHud;

@end

NS_ASSUME_NONNULL_END
