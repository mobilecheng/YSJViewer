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

@property (nonatomic) NSArray  *arrItems_iID, *arrItems_name, *arrItems_unit;
@property (nonatomic) NSString *cID, *sID;

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
    NSLog(@"RealTimeData -->  | CID = %@ | SID = %@", self.cID, self.sID);
    
    // 数据项- 压缩机 items
    self.arrItems_iID  = [saveData objectForKey:@"YSJ_Items_iID"];
    self.arrItems_name = [saveData objectForKey:@"YSJ_Items_name"];
    self.arrItems_unit = [saveData objectForKey:@"YSJ_Items_unit"];
    
    NSLog(@"RealTimeData -->  | Items_iID  = %@", self.arrItems_iID);
    NSLog(@"RealTimeData -->  | Items_name = %@", self.arrItems_name);
    NSLog(@"RealTimeData -->  | Items_unit = %@", self.arrItems_unit);
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get data.
    [self api_RealtimeData];
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
    return [self.arrItems_iID count];
//    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RealTimeData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labItems_name = (UILabel *)[cell viewWithTag:10];
    labItems_name.text = [self.arrItems_name objectAtIndex:indexPath.row];
    
    UILabel *labItems_value = (UILabel *)[cell viewWithTag:11];
    labItems_value.text = @"109.38";
    
    UILabel *labItems_unit = (UILabel *)[cell viewWithTag:12];
    NSString *strText = [self.arrItems_unit objectAtIndex:indexPath.row];
    strText = [NSString stringWithFormat:@"(%@)", strText];
    labItems_unit.text = strText;
    
    return cell;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */


#pragma mark -  API call.

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

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"--> RealTimeData -> Websocket Connected");
    
    //
//    [srWebSocket send:self.dataForID];
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
//    [self getCompressorStatus:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"--> RealTimeData -> WebSocket closed");
    
    srWebSocket = nil;
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

@end
