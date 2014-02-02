//
//  UserInfoUpdate.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "UserInfoUpdate.h"

@interface UserInfoUpdate ()

@end

@implementation UserInfoUpdate

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.txtEmail.text = @"1@2.cn";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
