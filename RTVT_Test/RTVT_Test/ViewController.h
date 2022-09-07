//
//  ViewController.h
//  RTAT_Test
//
//  Created by zsl on 2022/8/1.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "Masonry.h"
#import <RTVT/RTVT.h>

#define YS_Color_alpha(value, a) [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0  \
                                             green:((float)((value & 0xFF00) >> 8))/255.0     \
                                              blue:((float)(value & 0xFF))/255.0              \
                                             alpha:(a)/1.0]

@interface ViewController : UIViewController<RTVTProtocol,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)RTVTClient * client;
@property(nonatomic,strong)dispatch_source_t sendTimer;
@property(nonatomic,strong)NSMutableData * pcmData;
@property(nonatomic,assign)int64_t streamId;
@property(nonatomic,assign)int64_t seq;
@property(nonatomic,assign)int64_t authTime;
@property(nonatomic,strong)NSString * authToken;
@property(nonatomic,strong)NSString * srcLanguageString;
@property(nonatomic,strong)NSString * desLanguageString;

@property(nonatomic,strong)UIScrollView * bgScrollView;
@property(nonatomic,strong)UITableView * translatedTableView;
@property(nonatomic,strong)UITableView * recognizedTableView;
@property(nonatomic,strong)UIButton * loginButton;
@property(nonatomic,strong)UIButton * closeConnectButton;
@property(nonatomic,strong)UIButton * streamIdButton;
@property(nonatomic,strong)UIButton * closeSendButton;
@property(nonatomic,strong)NSMutableArray * translatedResultArray;
@property(nonatomic,strong)NSMutableArray * recognizedResultArray;
@property(nonatomic,strong)UIImageView * iconImageView;
@property(nonatomic,strong)UILabel * srcLanguageTitle;
@property(nonatomic,strong)UILabel * desLanguageTitle;
@property(nonatomic,strong)UIButton * srcLanguageButton;
@property(nonatomic,strong)UIButton * destLanguageButton;

@property(nonatomic,strong)UILabel * recognitionTitle;
@property(nonatomic,strong)UILabel * translateTitle;
@end



