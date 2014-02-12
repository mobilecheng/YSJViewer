//
//  RunRecord_TimeList_Detail.m
//  -- 主菜单 --> 设备监控--> 压缩机列表 --> 运行记录 --> 运行记录（时间列表）--> 指标数据
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-13.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RunRecord_TimeList_Detail.h"

@interface RunRecord_TimeList_Detail ()

@end

@implementation RunRecord_TimeList_Detail

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

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

@end
