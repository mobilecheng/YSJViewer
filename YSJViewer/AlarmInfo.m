//
//  AlarmInfo.m -- 主菜单 --> 报警信息
//  YSJViewer
//
//  Created by Kevin Zhang on 14-1-31.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "AlarmInfo.h"
#import "GlobalValue.h"

@interface AlarmInfo ()

@property (nonatomic) NSMutableArray *arrName;   // 压缩机名字
@property (nonatomic) NSMutableArray *arrAlarmInfo;     // 压缩机报警信息
@property (nonatomic) NSMutableArray *arrModel;  // 压缩机型号
@property (nonatomic) NSMutableArray *arrTime; // 压缩机报警时间

//@property (nonatomic) NSString *dataForQuery;

@end

@implementation AlarmInfo

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
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_GetAlarmData];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    srWebSocket = nil;
    
    NSLog(@"AlarmInfo --> viewDidDisappear -> _webSocket set nil.");
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlarmInfo_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // 压缩机名字
    UILabel *labName = (UILabel *)[cell viewWithTag:101];
    labName.text = [self.arrName objectAtIndex:indexPath.row];
    
    // 压缩机报警信息
    UILabel *labAlarmInfo = (UILabel *)[cell viewWithTag:102];
    labAlarmInfo.text = [self.arrAlarmInfo objectAtIndex:indexPath.row];
    
    // 压缩机型号
    UILabel *labModel = (UILabel *)[cell viewWithTag:103];
    labModel.text = [self.arrModel objectAtIndex:indexPath.row];
    
    // 压缩机报警时间
    UILabel *labTime = (UILabel *)[cell viewWithTag:104];
    labTime.text = [self.arrTime objectAtIndex:indexPath.row];
    
    //
    return cell;
}



#pragma mark -  Init Data.

- (void)initData
{
    self.arrName      = [[NSMutableArray alloc] init];
    self.arrAlarmInfo = [[NSMutableArray alloc] init];
    self.arrModel     = [[NSMutableArray alloc] init];
    self.arrTime      = [[NSMutableArray alloc] init];
    
}

#pragma mark -  API call.

- (void) api_GetAlarmData
{
    NSLog(@"--> api_GetAlarmData -> Opening WebSocket Connection...");
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    
    NSString *url = @"ws://117.34.92.46:3180/getAlarmdata";
    
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


#pragma mark - MBProgressHUD methods

// 显示收藏信息
- (void)showMessageHUD:(NSString *)msg {
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:delay];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"--> AlarmInfo -> Websocket Connected");
    
    NSString *dataForQuery = [[NSUserDefaults standardUserDefaults] stringForKey:@"dataForQuery"];
    NSLog(@"AlarmInfo --> 参数用于订阅信息查询 = %@", dataForQuery);
    
    //
    [srWebSocket send:dataForQuery];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"--> AlarmInfo ->  :( Websocket Failed With Error %@", error);
    
    srWebSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"--> AlarmInfo ->  Received =  %@", message);

    // 解析数据
//    [self getCompressorStatus:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"--> AlarmInfo -> WebSocket closed");
    
    srWebSocket = nil;
}


@end
