//
//  RunRecord_TimeList.m
//  -- 主菜单 --> 设备监控--> 压缩机列表 --> 运行记录 --> 运行记录（时间列表）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-12.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RunRecord_TimeList.h"
#import "GlobalValue.h"

@interface RunRecord_TimeList ()

@property (nonatomic) NSMutableArray *arrTimeList;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation RunRecord_TimeList

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

    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    // Title.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *name  = [saveData stringForKey:@"YSJ_NAME"];
    NSString *id    = [saveData stringForKey:@"YSJ_ID"];
    NSString *model = [saveData stringForKey:@"YSJ_MODEL"];
    NSString *prommpt = [NSString stringWithFormat:@"%@ %@ %@", name, id, model];
    self.navigationItem.prompt = prommpt;
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_RunReport];
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
    return self.arrTimeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RunRecord_TimeList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // 压缩机名字
    UILabel *labTimeList = (UILabel *)[cell viewWithTag:10];
    labTimeList.text = [self.arrTimeList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrTimeList      = [[NSMutableArray alloc] init];
    
}

#pragma mark -  API call.

- (void) api_RunReport
{
    NSLog(@"--> api_RunReport...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token    = [saveData objectForKey:@"Token"];
    NSString *compId   = [saveData objectForKey:@"YSJ_ID"];
    NSString *start    = [saveData objectForKey:@"StartTime"];
    NSString *end      = [saveData objectForKey:@"EndTime"];
    NSString *interval = [saveData objectForKey:@"TimeJG"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/runReport";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,    @"token",
                               compId,   @"compId",
                               start,    @"start",
                               end,      @"end",
                               interval, @"interval",
                               nil];
    
    NSLog(@"--> api_RunReport --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_RunReport -> RESULT = %@", str);
        
        [self getRunRecordData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_RunReport -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getRunRecordData:(id)theData
{
    NSError *error = nil;
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:theData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"--> ERROR = %@", error.description);
        return;
    }
    
    // Check result.
    NSString *strResult = [dicData objectForKey:@"result"];
    NSLog(@"--> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    NSArray *records = [dicData objectForKey:@"records"];
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    // 数据存储
//    NSMutableArray *arrTimeList = [[NSMutableArray alloc] init];
//    NSMutableArray *arrItems    = [[NSMutableArray alloc] init];
    
    // 解析数据
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        //
        NSString *date = [recordData objectForKey:@"date"];
        NSLog(@"DATA --> date     = %@", date);
        [self.arrTimeList addObject:date];
        
        //
//        NSArray *items = [recordData objectForKey:@"items"];
//        NSLog(@"DATA --> items     = %@", items);
//        [arrItems addObject:items];
    }
    
    // 刷新数据
    [self.tableView reloadData];
}

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

#pragma mark - MBProgressHUD methods

// 显示收藏信息
- (void)showMessageHUD:(NSString *)msg {
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:delay];
}

- (void) showLoadingHUD:(NSString *)msg
{
	MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	loadingHUD.mode = MBProgressHUDModeIndeterminate;
	loadingHUD.labelText = msg;
	loadingHUD.removeFromSuperViewOnHide = YES;
    [loadingHUD hide:YES afterDelay:delay];
}

@end
