//
//  ViewController+UI.m
//  RTVT_Test
//
//  Created by zsl on 2022/8/15.
//

#import "ViewController+UI.h"

@implementation ViewController (UI)
-(void)setUpUI{
    
    [self.view addSubview:self.bgScrollView];
    [self.bgScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.bgScrollView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.bgScrollView).offset(60);
        make.height.equalTo(@40);
        make.width.equalTo(@200);
    }];
    

    [self.bgScrollView addSubview:self.loginButton];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(30);
    }];


    [self.bgScrollView addSubview:self.closeConnectButton];
    [self.closeConnectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-30);
        make.top.equalTo(self.loginButton);
    }];

    [self.bgScrollView addSubview:self.srcLanguageTitle];
    [self.srcLanguageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.loginButton);
        make.top.equalTo(self.loginButton.mas_bottom).offset(30);
    }];
    
    [self.bgScrollView addSubview:self.srcLanguageButton];
    [self.srcLanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.srcLanguageTitle.mas_right);
        make.centerY.equalTo(self.srcLanguageTitle);
    }];


    [self.bgScrollView addSubview:self.destLanguageButton];
    [self.destLanguageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.srcLanguageButton);
        make.right.equalTo(self.closeConnectButton);
    }];
    
    [self.bgScrollView addSubview:self.desLanguageTitle];
    [self.desLanguageTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.destLanguageButton);
        make.right.equalTo(self.destLanguageButton.mas_left);
    }];


    [self.bgScrollView addSubview:self.streamIdButton];
    [self.streamIdButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.srcLanguageButton.mas_bottom).offset(30);
        make.left.equalTo(self.srcLanguageTitle);
    }];
    
    
    [self.bgScrollView addSubview:self.streamIdButtonCapture];
    [self.streamIdButtonCapture mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.streamIdButton);
        make.right.equalTo(self.destLanguageButton.mas_right);
    }];

    
    self.translatedResultArray = [NSMutableArray array];
    self.recognizedResultArray = [NSMutableArray array];
    
    self.tmpResultString = @"";
    self.tmpTransResultString = @"";
    
    
    [self.bgScrollView addSubview:self.recognitionTitle];
    [self.recognitionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.streamIdButton.mas_bottom).offset(30);
        make.left.equalTo(self.streamIdButton);
    }];
    [self.bgScrollView addSubview:self.recognizedTableView];
    [self.recognizedTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recognitionTitle.mas_bottom).offset(10);
        make.left.equalTo(self.recognitionTitle);
        make.right.equalTo(self.destLanguageButton);
        make.height.equalTo(@(160));
    }];

    [self.bgScrollView addSubview:self.translateTitle];
    [self.translateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recognizedTableView.mas_bottom).offset(20);
        make.left.equalTo(self.recognitionTitle);
    }];
    [self.bgScrollView addSubview:self.translatedTableView];
    [self.translatedTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.translateTitle.mas_bottom).offset(10);
        make.left.equalTo(self.translateTitle);
        make.right.equalTo(self.destLanguageButton);
        make.height.equalTo(@(160));
        
    }];
    
    
    [self.bgScrollView addSubview:self.closeSendButton];
    [self.closeSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.translatedTableView.mas_bottom).offset(30);
        make.left.equalTo(self.streamIdButton);
        make.bottom.equalTo(self.bgScrollView).offset(-60);
    }];
    
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.translatedTableView) {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId1"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId1"];
            cell.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.numberOfLines = 0;
        }
        
        if([self.destLanguageButton.titleLabel.text isEqualToString:@"ar"]){
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        }else{
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }

        
        
        if (indexPath.row == self.translatedResultArray.count) {
            cell.textLabel.text = self.tmpTransResultString;
            cell.textLabel.textColor = [UIColor systemPinkColor];
            
        }else{
            
            if (self.translatedResultArray.count - 1 >= indexPath.row ) {
                cell.textLabel.text = [self.translatedResultArray objectAtIndex:indexPath.row];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
        }
        
        return cell;
        
    }else if(tableView == self.recognizedTableView){
        
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId2"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId2"];
            cell.backgroundColor = [UIColor blackColor];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.numberOfLines = 0;
        }
        if([self.srcLanguageButton.titleLabel.text isEqualToString:@"ar"]){
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        }else{
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
        
        
        
        if (indexPath.row == self.recognizedResultArray.count) {
            cell.textLabel.text = self.tmpResultString;
            cell.textLabel.textColor = [UIColor systemPinkColor];
            
        }else{
            
            if (self.recognizedResultArray.count - 1 >= indexPath.row ) {
                cell.textLabel.text = [self.recognizedResultArray objectAtIndex:indexPath.row];
                cell.textLabel.textColor = [UIColor whiteColor];
            }
            
        }
        
        
        return cell;
        
    }else{
        
        return nil;
        
    }
    
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.translatedTableView) {
        
        return self.translatedResultArray.count +1;
        
    }else{
        
        return self.recognizedResultArray.count +1;
    }
}

- (void)showHudMessage:(NSString*)message hideTime:(int)hideTime{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        //hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        hud.label.textColor = [UIColor whiteColor];
        hud.label.numberOfLines = 0;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:hideTime];
        
    });
    
}


-(void)showLoadHud{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.removeFromSuperViewOnHide = true;
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        hud.contentColor = [UIColor whiteColor];
        hud.label.textColor = [UIColor whiteColor];
        
    });
    
}


@end
