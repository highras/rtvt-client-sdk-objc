//
//  ViewController.m
//  RTAT_Test
//
//  Created by zsl on 2022/8/1.
//


#import "ViewController.h"
#import "ViewController+UI.h"
#import "ViewController+Token.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()


@property(nonatomic,strong) AVAudioPlayer * _Nullable audioPlayer;
@property(nonatomic,strong) NSArray *  langArray;


@end

@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.langArray = [NSArray arrayWithObjects:@"zh",@"en",@"ja", nil];//添加语言
    //@"th"
    [self getToken];
    [self setUpUI];
    
}


#pragma mark click event
-(void)_loginClick{
 
    if (self.client == nil) {

        self.client = [RTVTClient clientWithEndpoint:@"rtvt.ilivedata.com:14001"
                                           projectId:90008000
                                              userId:666
                                            delegate:self];
        

    }
    
    [self showLoadHud];
    [self.client loginWithToken:self.authToken
                       authTime:self.authTime
                        success:^{

        [self showHudMessage:@"登录成功" hideTime:1];
        NSLog(@"login success");

    } connectFail:^(FPNError * _Nullable error) {

        [self showHudMessage:[NSString stringWithFormat:@"登录失败%@",error.ex] hideTime:2];
        NSLog(@"login fail %@",error);

    }];
    
}
-(void)_loadFileAndSend{
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.pcm",self.srcLanguageButton.titleLabel.text] ofType:nil];
    self.pcmData = [NSMutableData dataWithContentsOfFile:filePath];
    uint64_t interval = 0.02 * NSEC_PER_SEC;
    dispatch_queue_t pingTimerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (self.sendTimer == nil) {
        self.sendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, pingTimerQueue);
        dispatch_source_set_timer(self.sendTimer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
        dispatch_source_set_event_handler(self.sendTimer, ^(){
            [self _sendData];
        });
    }
    dispatch_resume(self.sendTimer);
    
}
-(void)_closeConnectClick{
    
    [self.client closeConnect];
    [self _endTimer];
    
}
-(void)_destLanguageClick{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0; i < self.langArray.count; i++) {
        
        if ([self.srcLanguageButton.titleLabel.text isEqualToString:[self.langArray objectAtIndex:i]] == NO) {
            UIAlertAction *languageType = [UIAlertAction actionWithTitle:[self.langArray objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.destLanguageButton setTitle:[self.langArray objectAtIndex:i] forState:UIControlStateNormal];
            }];
            [alertVc addAction:languageType];
        }
        
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull   action) {
        
    }];
    [cancel setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertVc addAction:cancel];
    
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
-(void)_srcLanguageClick{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (int i = 0; i < self.langArray.count; i++) {
        
        if ([self.destLanguageButton.titleLabel.text isEqualToString:[self.langArray objectAtIndex:i]] == NO) {
            UIAlertAction *languageType = [UIAlertAction actionWithTitle:[self.langArray objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.srcLanguageButton setTitle:[self.langArray objectAtIndex:i] forState:UIControlStateNormal];
            }];
            [alertVc addAction:languageType];
        }
        
    }

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull   action) {
        
    }];
    [cancel setValue:[UIColor redColor] forKey:@"titleTextColor"];
    [alertVc addAction:cancel];
    
    [self presentViewController:alertVc animated:YES completion:nil];
    
}
-(void)_sendData{
    
    @synchronized (self) {
        
        if (self.streamId != 0) {
            
            //采样率 / 帧数 * short * 声道数
            int byteL = 16000 / 50 * sizeof(short) * 1;
            if (self.pcmData.length > byteL) {
                
                NSData * perFramePcmData = [self.pcmData subdataWithRange:NSMakeRange(0, byteL)];
//                int16_t * xx = perFramePcmData.bytes;
                [self.pcmData replaceBytesInRange:NSMakeRange(0, byteL) withBytes:NULL length:0];
//                NSLog(@"%lu  %lu",(unsigned long)perFramePcmData.length,(unsigned long)self.pcmData.length);
                self.seq = self.seq + 1;
                
                [self.client sendVoiceWithStreamId:self.streamId
                                         voiceData:perFramePcmData
                                               seq:self.seq
                                                ts:0
                                           success:^{
                    
                } fail:^(FPNError * _Nullable error) {
                    
                    
                }];
                
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showHudMessage:@"测试结束" hideTime:1];
                    [self _endTimer];
                });
                
            }
            
        }
        
    }
    
}

-(void)_streamIdClick{
    
    if ([self.srcLanguageButton.titleLabel.text isEqualToString:@"请选择源语言"]) {
        [self showHudMessage:@"请选择源语言" hideTime:2];
        return;
    }
    if ([self.destLanguageButton.titleLabel.text isEqualToString:@"请选择目标语言"]) {
        [self showHudMessage:@"请选择目标语言" hideTime:2];
        return;
    }
    if (self.streamId == 0) {
        
        [self showLoadHud];
        [self.client starStreamTranslateWithAsrResult:YES
                                          srcLanguage:self.srcLanguageButton.titleLabel.text
                                         destLanguage:self.destLanguageButton.titleLabel.text
                                              success:^(int64_t streamId) {
            
            [self showHudMessage:[NSString stringWithFormat:@"获取streamId成功 id = %lld 开始测试",streamId] hideTime:2];
            
            @synchronized (self) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.recognizedResultArray removeAllObjects];
                    [self.translatedResultArray removeAllObjects];
                    [self.recognizedTableView reloadData];
                    [self.translatedTableView reloadData];
                    
                    self.streamId = streamId;
                    [self _loadFileAndSend];
                    [self.audioPlayer stop];
                    [self _playVoice];
                });
                
            }
            
        } fail:^(FPNError * _Nullable error) {
            
            [self showHudMessage:[NSString stringWithFormat:@"获取streamId fail %@",error.ex] hideTime:2];
            
        }];
        
    }
    
}
-(void)_playVoice{
    
    NSString * filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",self.srcLanguageButton.titleLabel.text] ofType:@"wav"];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    self.audioPlayer = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:filePath] error:nil];
    [self.audioPlayer play];
}
-(void)_closeSend{
    
    if (self.streamId != 0) {
        
        [self showLoadHud];
        [self.client endTranslateWithStreamId:self.streamId
                                      lastSeq:self.seq
                                      success:^{
            
        [self showHudMessage:[NSString stringWithFormat:@"结束发送 success = %lld",self.streamId] hideTime:1];
            
            [self _endTimer];
            
            
        } fail:^(FPNError * _Nullable error) {
            
            [self showHudMessage:[NSString stringWithFormat:@"结束发送 fail = %@",error.ex] hideTime:2];
            
        }];
        
    }else{
        
        [self showHudMessage:@"streamId is nil" hideTime:1];
        
    }
    
}










#pragma mark rtvt delegate
//@required
//语音翻译
-(void)translatedResultWithStreamId:(int64_t)streamId
                            startTs:(int)startTs
                              endTs:(int)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int)recTs{
    
//    NSLog(@"翻译结果 = %@   streamId = %d",result,streamId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.translatedResultArray addObject:result];
        [self.translatedTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.translatedResultArray.count - 1 inSection:0];
        [self.translatedTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
}


//@optional
//语音识别
-(void)recognizedResultWithStreamId:(int64_t)streamId
                            startTs:(int)startTs
                              endTs:(int)endTs
                             result:(NSString * _Nullable)result
                              recTs:(int)recTs{
    
//    NSLog(@"识别结果 = %@   streamId = %d",result,streamId);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.recognizedResultArray addObject:result];
        [self.recognizedTableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.recognizedResultArray.count - 1 inSection:0];
        [self.recognizedTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
}

//重连将要开始  根据返回值是否进行重连
-(BOOL)rtvtReloginWillStart:(RTVTClient *)client reloginCount:(int)reloginCount{
    
    NSLog(@"%s ",__FUNCTION__);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHudMessage:@"重连中" hideTime:99999];
        [self _endTimer];
        
    });
    
    return YES;
    
}
//重连结果
-(void)rtvtReloginCompleted:(RTVTClient *)client reloginCount:(int)reloginCount reloginResult:(BOOL)reloginResult error:(FPNError*)error{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (reloginResult == YES) {
            
            [self showHudMessage:@"重连成功" hideTime:2];
            
        }else{
            
            [self showHudMessage:@"重连失败 继续重连" hideTime:2];
            
        }
        
    });
    
    
    NSLog(@"%s %d %@",__FUNCTION__,reloginResult,error.ex);
    
}
//关闭连接
-(void)rtvtConnectClose:(RTVTClient *)client{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showHudMessage:@"连接已中断" hideTime:2];
        [self _endTimer];
        
    });
    NSLog(@"%s ",__FUNCTION__);
    
}
-(void)_endTimer{
    @synchronized (self) {
        self.streamId = 0;
        if (self.sendTimer != nil) {
            dispatch_cancel(self.sendTimer);
            self.sendTimer = nil;
            [self.audioPlayer stop];
        }
    }
}



#pragma mark get
-(UIButton*)loginButton{
    if (_loginButton == nil) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_loginButton setTitle:@"点击登录" forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(_loginClick) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.backgroundColor = YS_Color_alpha(0x1b9fff,1);
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _loginButton;
}
-(UIButton*)streamIdButton{
    if (_streamIdButton == nil) {
        _streamIdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _streamIdButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_streamIdButton setTitle:@"申请streamId,并开始发送数据进行测试" forState:UIControlStateNormal];
        [_streamIdButton addTarget:self action:@selector(_streamIdClick) forControlEvents:UIControlEventTouchUpInside];
        _streamIdButton.backgroundColor = YS_Color_alpha(0x1b9fff,1);
        [_streamIdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _streamIdButton;
}
-(UIButton*)closeSendButton{
    if (_closeSendButton == nil) {
        _closeSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeSendButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_closeSendButton setTitle:@"结束发送(对应streamId)" forState:UIControlStateNormal];
        [_closeSendButton addTarget:self action:@selector(_closeSend) forControlEvents:UIControlEventTouchUpInside];
        _closeSendButton.backgroundColor = [UIColor redColor];
        [_closeSendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _closeSendButton;
}
-(UIButton*)closeConnectButton{
    if (_closeConnectButton == nil) {
        _closeConnectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeConnectButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_closeConnectButton setTitle:@"退出登录" forState:UIControlStateNormal];
        [_closeConnectButton addTarget:self action:@selector(_closeConnectClick) forControlEvents:UIControlEventTouchUpInside];
        _closeConnectButton.backgroundColor = [UIColor redColor];
        [_closeConnectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _closeConnectButton;
}
-(UIButton*)srcLanguageButton{
    if (_srcLanguageButton == nil) {
        _srcLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _srcLanguageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_srcLanguageButton setTitle:@"请选择源语言" forState:UIControlStateNormal];
        [_srcLanguageButton addTarget:self action:@selector(_srcLanguageClick) forControlEvents:UIControlEventTouchUpInside];
        _srcLanguageButton.backgroundColor = YS_Color_alpha(0x1b9fff,1);
        [_srcLanguageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _srcLanguageButton;
}
-(UIButton*)destLanguageButton{
    if (_destLanguageButton == nil) {
        _destLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _destLanguageButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_destLanguageButton setTitle:@"请选择目标语言" forState:UIControlStateNormal];
        [_destLanguageButton addTarget:self action:@selector(_destLanguageClick) forControlEvents:UIControlEventTouchUpInside];
        _destLanguageButton.backgroundColor = YS_Color_alpha(0x1b9fff,1);
    }
    return _destLanguageButton;
}
-(UITableView*)translatedTableView{
    if (_translatedTableView == nil) {
        _translatedTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _translatedTableView.backgroundColor = [UIColor blackColor];
        _translatedTableView.delegate = self;
        _translatedTableView.dataSource = self;
        _translatedTableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _translatedTableView;
}
-(UITableView*)recognizedTableView{
    if (_recognizedTableView == nil) {
        _recognizedTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _recognizedTableView.backgroundColor = [UIColor blackColor];
        _recognizedTableView.delegate = self;
        _recognizedTableView.dataSource = self;
        _recognizedTableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _recognizedTableView;
}
-(UIImageView*)iconImageView{
    if (_iconImageView == nil) {
        _iconImageView = [UIImageView new];
        _iconImageView.image = [UIImage imageNamed:@"logo"];
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconImageView;
}
-(UILabel*)srcLanguageTitle{
    if (_srcLanguageTitle == nil) {
        _srcLanguageTitle = [UILabel new];
        _srcLanguageTitle.font = [UIFont systemFontOfSize:12];
        _srcLanguageTitle.textColor = [UIColor blackColor];
        _srcLanguageTitle.text = @"源语音:";
    }
    return _srcLanguageTitle;
}
-(UILabel*)desLanguageTitle{
    if (_desLanguageTitle == nil) {
        _desLanguageTitle = [UILabel new];
        _desLanguageTitle.font = [UIFont systemFontOfSize:12];
        _desLanguageTitle.textColor = [UIColor blackColor];
        _desLanguageTitle.text = @"目标语音:";
    }
    return _desLanguageTitle;
}

-(UILabel*)recognitionTitle{
    if (_recognitionTitle == nil) {
        _recognitionTitle = [UILabel new];
        _recognitionTitle.font = [UIFont systemFontOfSize:12];
        _recognitionTitle.textColor = [UIColor blackColor];
        _recognitionTitle.text = @"识别结果: ";
    }
    return _recognitionTitle;
}
-(UILabel*)translateTitle{
    if (_translateTitle == nil) {
        _translateTitle = [UILabel new];
        _translateTitle.font = [UIFont systemFontOfSize:12];
        _translateTitle.textColor = [UIColor blackColor];
        _translateTitle.text = @"翻译结果: ";
    }
    return _translateTitle;
}

-(UIScrollView*)bgScrollView{
    if (_bgScrollView == nil) {
        _bgScrollView = [UIScrollView new];
        _bgScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _bgScrollView;
}
@end


