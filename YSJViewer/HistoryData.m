//
//  HistoryData.m -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-历史数据）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-11.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "HistoryData.h"

@interface HistoryData ()

//@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation HistoryData

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.myTableView = [[UITableView alloc] init];
//    self.myTableView.delegate = self;
//    self.myTableView.dataSource = self;
//    [self.view addSubview:self.myTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"历史数据数据量很大，请尽量在免费WIFI下使用";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"StartTime";
            break;
        case 1:
            CellIdentifier = @"EndTime";
            break;
        case 2:
            CellIdentifier = @"JCL";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    MyDailyCell *cell =(MyDailyCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
////        cell = [[[MyDailyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//    }
    
    // Configure the cell...
    
    return cell;
}


@end
