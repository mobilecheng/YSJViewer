//
//  UserInfoUpdate.h
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoUpdate : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtOfficeTel;
@property (weak, nonatomic) IBOutlet UITextField *txtMobilePhone;
@property (weak, nonatomic) IBOutlet UITextField *txtFax;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end
