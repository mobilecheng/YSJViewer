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

@property (nonatomic) NSArray *arrDetailName;
@property (nonatomic) NSArray *arrDetailValue;

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

    // get data.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.arrDetailName  = [saveData objectForKey:@"RRTItemNames"];
    self.arrDetailValue = [saveData objectForKey:@"RRTItemValues"];
    NSLog(@"RRTD --> | arrDetailName = %@ | arrDetailValue = %@",
          self.arrDetailName, self.arrDetailValue);
    
    [self setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"RRTD --> | self.arrDetailName.count = %d", self.arrDetailName.count);
    return self.arrDetailName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RRTDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labDetail_name = (UILabel *)[cell viewWithTag:10];
    labDetail_name.text = [self.arrDetailName objectAtIndex:indexPath.row];
    
    UILabel *labDetail_value = (UILabel *)[cell viewWithTag:11];
    labDetail_value.text = [self.arrDetailValue objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

@end
