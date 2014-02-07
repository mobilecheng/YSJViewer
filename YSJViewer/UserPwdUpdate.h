//
//  UserPwdUpdate.h -- 主菜单 --> 用户信息 --> 修改密码
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserPwdUpdate : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmNewPwd;

@property (nonatomic) MKNetworkEngine *engine;

- (IBAction)buttonClick;

@end
