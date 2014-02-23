//
//  ReserveHistory.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-预约历史）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-23.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "ReserveHistory.h"
#import "GlobalValue.h"

@interface ReserveHistory ()

@property (nonatomic) NSMutableArray *arrID;
@property (nonatomic) NSMutableArray *arrDescription;
@property (nonatomic) NSMutableArray *arrState;
@property (nonatomic) NSMutableArray *arrExpectDate;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation ReserveHistory

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
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_GetServiceRequest];
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
    return self.arrDescription.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReserveHistory_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labDescription = (UILabel *)[cell viewWithTag:10];
    labDescription.text = [self.arrDescription objectAtIndex:indexPath.row];
    
    UILabel *labExpectDate = (UILabel *)[cell viewWithTag:11];
    labExpectDate.text = [self.arrExpectDate objectAtIndex:indexPath.row];
    
    UILabel *labState = (UILabel *)[cell viewWithTag:12];
    labState.text = [self.arrState objectAtIndex:indexPath.row];
    
    //
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *iID  = [self.arrID objectAtIndex:indexPath.row];
    NSLog(@"iID = %@", iID);
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:iID  forKey:@"RESERVE_ID"];
    [saveData synchronize];
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrID          = [[NSMutableArray alloc] init];
    self.arrDescription = [[NSMutableArray alloc] init];
    self.arrState       = [[NSMutableArray alloc] init];
    self.arrExpectDate  = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

// API -获取指定压缩机服务申请
- (void) api_GetServiceRequest
{
    NSLog(@"--> api_GetServiceRequest...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *compId = [saveData  objectForKey:@"YSJ_ID"];
    NSString *max    = @"100";
    NSString *offset = @"0";
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getServiceRequest";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,  @"token",
                               max,    @"max",
                               offset, @"offset",
                               compId, @"compId",
                               nil];
    
    NSLog(@"--> api_GetServiceRequest -> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetServiceRequest -> RESULT = %@", str);
        
        [self getServiceRequest:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetServiceRequest -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getServiceRequest:(id)theData
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
    NSLog(@"--> COUNT = %d", [records count]);
    if (records.count == 0) {
        [self showMessageHUD:@"没有服务申请数据."];
        return;
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        //
        NSLog(@"DATA --> id     = %@", [recordData objectForKey:@"id"]);
        [self.arrID addObject:[recordData objectForKey:@"id"]];
        
        //
        NSLog(@"DATA --> description     = %@", [recordData objectForKey:@"description"]);
        [self.arrDescription addObject:[recordData objectForKey:@"description"]];
        
        //
        NSLog(@"DATA --> state     = %@", [recordData objectForKey:@"state"]);
        [self.arrState addObject:[recordData objectForKey:@"state"]];
        
        //
        NSLog(@"DATA --> expectDate     = %@", [recordData objectForKey:@"expectDate"]);
        [self.arrExpectDate addObject:[recordData objectForKey:@"expectDate"]];
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
