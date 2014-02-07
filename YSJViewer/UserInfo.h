//
//  UserInfo.h -- 主菜单 --> 用户信息
//  YSJViewer
//
//  Created by Kevin Zhang on 14-1-15.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfo : UITableViewController


@property (weak, nonatomic) IBOutlet UILabel *labUserName;
@property (weak, nonatomic) IBOutlet UILabel *labOfficePhone;
@property (weak, nonatomic) IBOutlet UILabel *labMobilePhone;
@property (weak, nonatomic) IBOutlet UILabel *labFax;
@property (weak, nonatomic) IBOutlet UILabel *labEmail;

@end
