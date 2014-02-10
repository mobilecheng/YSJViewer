//
//  RealTimeData.m -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-实时数据）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RealTimeData.h"
#import "GlobalValue.h"

@interface RealTimeData ()

@property (nonatomic) NSString *cID;
@property (nonatomic) NSString *sID;

@property (nonatomic) NSMutableArray *arrItems_iID;
@property (nonatomic) NSMutableArray *arrItems_name;
@property (nonatomic) NSMutableArray *arrItems_value;

//@property (nonatomic) NSMutableArray *tmpID;
//@property (nonatomic) NSMutableArray *tmpValue;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation RealTimeData

#pragma mark -  View life cycle.

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
    self.navigationItem.title = [saveData stringForKey:@"YSJ_NAME"];
    
    // 数据项
//    self.arrMenu = [NSArray arrayWithObjects:
//               @"末级级间温度", @"进油温度", @"电机前轴承温度", @"电机后轴承温度",
//               @"电机定子温度", @"第一级级间温度", @"后冷空气温度", nil];
    
    
    // cID, sID.
    self.cID  = [saveData objectForKey:@"YSJ_CID"];
    self.sID  = [saveData objectForKey:@"YSJ_SID"];
//    NSLog(@"RealTimeData -->  | CID = %@ | SID = %@", self.cID, self.sID);
    
    // Comment on 2-10 - 原因： 接口返回这些值
    /*
    // 数据项- 压缩机 items
    self.arrItems_iID  = [saveData objectForKey:@"YSJ_Items_iID"];
    self.arrItems_name = [saveData objectForKey:@"YSJ_Items_name"];
    self.arrItems_unit = [saveData objectForKey:@"YSJ_Items_unit"];
    
    NSLog(@"RealTimeData -->  | Items_iID  = %@", self.arrItems_iID);
    NSLog(@"RealTimeData -->  | Items_name = %@", self.arrItems_name);
    NSLog(@"RealTimeData -->  | Items_unit = %@", self.arrItems_unit);
    */
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_GetCurrentData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get data.
//    [self api_RealtimeData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    srWebSocket = nil;
    
    NSLog(@"viewDidDisappear -> _webSocket set nil.");
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
    return [self.arrItems_name count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RealTimeData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labItems_name = (UILabel *)[cell viewWithTag:10];
    labItems_name.text = [self.arrItems_name objectAtIndex:indexPath.row];
    
    UILabel *labItems_value = (UILabel *)[cell viewWithTag:11];
    labItems_value.text = [self.arrItems_value objectAtIndex:indexPath.row];
    
//    UILabel *labItems_unit = (UILabel *)[cell viewWithTag:12];
//    NSString *strText = [self.arrItems_unit objectAtIndex:indexPath.row];
//    strText = [NSString stringWithFormat:@"(%@)", strText];
//    labItems_unit.text = strText;
    
    return cell;
}


#pragma mark -  Init Data.

- (void)initData
{
    self.arrItems_name  = [[NSMutableArray alloc] init];
    self.arrItems_value = [[NSMutableArray alloc] init];
    self.arrItems_iID   = [[NSMutableArray alloc] init];
//    self.tmpID          = [[NSMutableArray alloc] init];
//    self.tmpValue       = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

// API - 实时数据初始化
- (void) api_GetCurrentData
{
    NSLog(@"--> api_GetCurrentData...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *compId = [saveData  objectForKey:@"YSJ_ID"];
    NSLog(@"--> api_GetCurrentData -> compId = %@", compId);
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getCurrentData";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token", compId, @"compId", nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetCurrentData -> RESULT = %@", str);
        
        [self getCurrentData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetCurrentData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getCurrentData:(id)theData
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
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        NSLog(@"DATA --> name     = %@", [recordData objectForKey:@"name"]);
        [self.arrItems_name addObject:[recordData objectForKey:@"name"]];
        
        //
        NSLog(@"DATA --> 检测量编号     = %@", [recordData objectForKey:@"iId"]);
        [self.arrItems_iID addObject:[recordData objectForKey:@"iId"]];
        
        //
        NSString *unit  = [recordData objectForKey:@"unit"];
        NSString *value = [recordData objectForKey:@"value"];
        value = [NSString stringWithFormat:@"%@ (%@)", value, unit];
        NSLog(@"DATA --> value    = %@", value);
        [self.arrItems_value addObject:value];
    }
    
    // 刷新数据
    [self.tableView reloadData];
    
    // 订阅实时数据
    [self api_RealtimeData];
}

// 订阅实时数据
- (void) api_RealtimeData
{
    NSLog(@"--> api_RealtimeData -> Opening WebSocket Connection...");
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    
    NSString *url = @"ws://117.34.92.46:3180/getrealtimedata";
    
    srWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    srWebSocket.delegate = self;
    
    [srWebSocket open];
}

// 解析实时数据
- (void) getRealtimeData:(id)theData
{
    NSError *error = nil;
    NSData  *aData = [theData dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:aData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        NSLog(@"--> ERROR = %@", error.description);
        return;
    }
    
    // Check result.
    NSString *strResult = [dicData objectForKey:@"result"];
    NSLog(@"--> getRealtimeData -> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    // 解析数据
    NSArray *records = [dicData objectForKey:@"data"];
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    // 临时变量
    NSMutableArray *tmpID    = [[NSMutableArray alloc] init];
    NSMutableArray *tmpValue = [[NSMutableArray alloc] init];
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        NSString *unit  = [recordData objectForKey:@"unit"];
        NSString *value = [recordData objectForKey:@"value"];
        value = [NSString stringWithFormat:@"%@ (%@)", value, unit];
        NSLog(@"  -- REAL DATA --> value    = %@", value);
        [tmpValue addObject:value];
        
        NSString *iId = [recordData objectForKey:@"iId"];
        NSLog(@"  -- REAL DATA --> iId  = %@", iId);
        [tmpID addObject:iId];
    }
    
    // 更新数据
    [self.arrItems_value removeAllObjects];
    for (int i = 0; i < self.arrItems_iID.count; i++) {
        int val_iID = [[self.arrItems_iID objectAtIndex:i] intValue];
//        NSLog(@"  -- REAL DATA --> val_iID  = %d", val_iID);
        
        for (int j = 0; j < tmpID.count; j++) {
            int val_tmpID = [[tmpID objectAtIndex:j] intValue];
//            NSLog(@"  -- REAL DATA --> val_tmpID  = %d", val_tmpID);
            
            if (val_iID == val_tmpID) { // 找到相同的检测量
                [self.arrItems_value addObject:[tmpValue objectAtIndex:j]];
                break;
            }
        }
    }
    
    // 刷新数据
    [self.tableView reloadData];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"--> RealTimeData -> Websocket Connected");
    
    // 构造参数，用于订阅信息查询
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.sID, @"sId", self.cID, @"cId", nil];
    NSString *idInfo = [params jsonEncodedKeyValueString];
    NSLog(@"构造参数 = %@", idInfo);
    [srWebSocket send:idInfo];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"--> RealTimeData ->  :( Websocket Failed With Error %@", error);
    
    srWebSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"--> RealTimeData ->  Received =  %@", message);
    
    //    if ([message isKindOfClass:[NSString class]]) {
    //        NSLog(@"--> YSJ_List ->  Received =  NSString");
    //    } else if ([message isKindOfClass:[NSData class]]) {
    //        NSLog(@"--> YSJ_List ->  Received =  NSData");
    //    } else if (message == nil) {
    //        NSLog(@"--> YSJ_List ->  Received =  nil");
    //    } else {
    //        NSLog(@"--> YSJ_List ->  Received =  nothing...");
    //    }
    
    // 解析数据
    [self getRealtimeData:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"--> RealTimeData -> WebSocket closed");
    
    srWebSocket = nil;
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
