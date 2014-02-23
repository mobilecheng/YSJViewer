//
//  YSJ_List_TVC.m -- 主菜单 --> 设备监控（一级页面-压缩机列表）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-5.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "YSJ_List_TVC.h"
#import "GlobalValue.h"

@interface YSJ_List_TVC ()

@property (nonatomic) NSMutableArray *arrName;   // 压缩机名字
@property (nonatomic) NSMutableArray *arrID;   // 压缩机ID
@property (nonatomic) NSMutableArray *arrSN;     // 压缩机编号
@property (nonatomic) NSMutableArray *arrModel;  // 压缩机型号
@property (nonatomic) NSMutableArray *arrStatus; // 压缩机状态（在线、离线）
@property (nonatomic) NSMutableArray *arrSID;  // 用于订阅数据查询
@property (nonatomic) NSMutableArray *arrCID;  // 用于订阅数据查询
@property (nonatomic) NSMutableArray *arrItems_iID;  // 压缩机数据项
@property (nonatomic) NSMutableArray *arrItems_name;  // 压缩机数据项
@property (nonatomic) NSMutableArray *arrItems_unit;  // 压缩机数据项

@property (nonatomic) MKNetworkEngine *engine;

@property (nonatomic) NSString *dataForID;

@end

@implementation YSJ_List_TVC

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
    
    //
    self.engine = [[MKNetworkEngine alloc]
                               initWithHostName:hostName
                               customHeaderFields:nil];
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_CompressorList];
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
    NSLog(@"压缩机数量 = %d", [self.arrName count]);
    return [self.arrName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YSJ_List_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Cell Image Icon
//    UIImageView *cellIcon = (UIImageView *)[cell viewWithTag:100];
//    cellIcon.image = [self imageForRating:player.rating];
    
    // 压缩机名字
    UILabel *labName = (UILabel *)[cell viewWithTag:101];
    labName.text = [self.arrName objectAtIndex:indexPath.row];
    
    // 压缩机编号
    UILabel *labSN = (UILabel *)[cell viewWithTag:102];
    labSN.text = [self.arrSN objectAtIndex:indexPath.row];
    
    // 压缩机型号
    UILabel *labModel = (UILabel *)[cell viewWithTag:103];
    labModel.text = [self.arrModel objectAtIndex:indexPath.row];
    
    // 压缩机状态
    UILabel *labStatus = (UILabel *)[cell viewWithTag:104];
    if (self.arrStatus.count != 0) {
        NSString  *status = [self.arrStatus  objectAtIndex:indexPath.row];
        NSInteger val     = [status intValue];
        if (val == 1) {
            labStatus.text = @"在线";
            labStatus.backgroundColor = [UIColor greenColor];
        } else {
            labStatus.text = @"离线";
            labStatus.backgroundColor = [UIColor grayColor];
        }
    }
    
    //
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name  = [self.arrName objectAtIndex:indexPath.row];
    NSString *ysjID = [self.arrID   objectAtIndex:indexPath.row]; // 压缩机ID
    NSString *model = [self.arrModel objectAtIndex:indexPath.row]; // 压缩机型号
    NSString *cid   = [self.arrCID  objectAtIndex:indexPath.row];
    NSString *sid   = [self.arrSID  objectAtIndex:indexPath.row];
    
    // add 2-23
    NSString *strCSN   = [self.arrSN  objectAtIndex:indexPath.row];
    
    NSLog(@"YSJ name = %@ | ID = %@ | CID = %@ | SID = %@", name, ysjID, cid, sid);
    
    NSArray *items_iID  = [self.arrItems_iID  objectAtIndex:indexPath.row];
    NSLog(@"items_iID  = %@", items_iID);
    
    NSArray *items_name  = [self.arrItems_name  objectAtIndex:indexPath.row];
    NSLog(@"items_name = %@", items_name);
    
    NSArray *items_unit  = [self.arrItems_unit  objectAtIndex:indexPath.row];
    NSLog(@"items_unit = %@", items_unit);
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    [saveData setObject:name  forKey:@"YSJ_NAME"];
    [saveData setObject:ysjID forKey:@"YSJ_ID"];
    [saveData setObject:cid   forKey:@"YSJ_CID"];
    [saveData setObject:sid   forKey:@"YSJ_SID"];
    [saveData setObject:model forKey:@"YSJ_MODEL"];
    
    // add 2-23
    [saveData setObject:strCSN forKey:@"YSJ_CSN"];
    
    [saveData setObject:items_iID   forKey:@"YSJ_Items_iID"];
    [saveData setObject:items_name  forKey:@"YSJ_Items_name"];
    [saveData setObject:items_unit  forKey:@"YSJ_Items_unit"];
    
    [saveData synchronize];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


#pragma mark -  Init Data.

- (void)initData
{
    self.arrName   = [[NSMutableArray alloc] init];
    self.arrID     = [[NSMutableArray alloc] init];
    self.arrSN     = [[NSMutableArray alloc] init];
    self.arrModel  = [[NSMutableArray alloc] init];
    self.arrStatus = [[NSMutableArray alloc] init];
    self.arrSID    = [[NSMutableArray alloc] init];
    self.arrCID    = [[NSMutableArray alloc] init];
    
    self.arrItems_iID  = [[NSMutableArray alloc] init];
    self.arrItems_name = [[NSMutableArray alloc] init];
    self.arrItems_unit = [[NSMutableArray alloc] init];
}


#pragma mark -  API call.

- (void) api_CompressorList
{
    NSLog(@"--> apiCompressorList");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getCompressorList";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                params:dicParams
                                            httpMethod:@"GET"
                                                   ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> apiCompressorList -> RESULT = %@", str);
        
        [self getCompressorList:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> apiCompressorList -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) getCompressorList:(id)theData
{
    NSError *error = nil;
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:theData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        
        // Check result.
        NSString *strResult = [dicData objectForKey:@"result"];
        NSLog(@"--> strResult = %@", strResult);
        if ([strResult isEqualToString:@"error"]) {
            [self showMessageHUD:[dicData objectForKey:@"message"]];
            return;
        }
        
        NSArray *records = [dicData objectForKey:@"records"];
        NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
        
        // 构造参数，用于订阅信息查询
        NSMutableArray *tempIDInfo = [[NSMutableArray alloc] init];
        
        //
        for (NSDictionary *recordData in records) {
            NSLog(@"---------------------------------------");
            
            NSLog(@"DATA --> alias   = %@", [recordData objectForKey:@"alias"]);
            [self.arrName addObject:[recordData objectForKey:@"alias"]];
            
            NSLog(@"DATA --> 压缩机ID   = %@", [recordData objectForKey:@"id"]);
            [self.arrID addObject:[recordData objectForKey:@"id"]];
            
            NSLog(@"DATA --> cSN     = %@", [recordData objectForKey:@"cSN"]);
            [self.arrSN addObject:[recordData objectForKey:@"cSN"]];
            
            NSLog(@"DATA --> model   = %@", [recordData objectForKey:@"model"]);
            [self.arrModel addObject:[recordData objectForKey:@"model"]];
            
            NSString *cId = [recordData objectForKey:@"cId"];
            NSLog(@"DATA --> cId     = %@", cId);
            [self.arrCID addObject:cId];
            
            NSString *sID = [recordData objectForKey:@"sId"];
            NSLog(@"DATA --> sId     = %@", sID);
            [self.arrSID addObject:sID];
            
            // 构造参数，用于订阅信息查询
            NSDictionary *idInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               sID, @"sId", cId, @"cId", nil];
            [tempIDInfo addObject:idInfo];
            
            
            // Items
//            NSLog(@"    ---> ------------------------------------");
            NSMutableArray *tempIID   = [[NSMutableArray alloc] init];
            NSMutableArray *tempName  = [[NSMutableArray alloc] init];
            NSMutableArray *tempUnit  = [[NSMutableArray alloc] init];
            
            NSArray *items = [recordData objectForKey:@"items"];  // Get All items.
            
            for (NSDictionary *itemData in items) {
//                NSLog(@"    ITEMS --> iId   = %@", [itemData objectForKey:@"iId"]);
                [tempIID  addObject:[itemData objectForKey:@"iId"]];
                
//                NSLog(@"    ITEMS --> name   = %@", [itemData objectForKey:@"name"]);
                [tempName addObject:[itemData objectForKey:@"name"]];
                
//                NSLog(@"    ITEMS --> unit   = %@", [itemData objectForKey:@"unit"]);
                [tempUnit addObject:[itemData objectForKey:@"unit"]];
            }
            
            // Save items data.
            [self.arrItems_iID  addObject:tempIID];
            [self.arrItems_name addObject:tempName];
            [self.arrItems_unit addObject:tempUnit];
        }
        
        // 构造参数，用于订阅信息查询
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                tempIDInfo, @"data", nil];
        self.dataForID = [params jsonEncodedKeyValueString];
        NSLog(@"--> 参数用于订阅信息查询 = %@", self.dataForID);
        
        // 取压缩机状态
        [self api_GetCompressorStatus];
        
        // 刷新数据
        [self.tableView reloadData];
        
    } else {
        NSLog(@"--> ERROR = %@", error.description);
    }
}


- (void) api_GetCompressorStatus
{
    NSLog(@"--> api_getCompressorStatus -> Opening WebSocket Connection...");
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    
    NSString *url = @"ws://117.34.92.46:3180/getCompressorStatus";
    //    url = @"ws://echo.websocket.org";
    
    srWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    srWebSocket.delegate = self;
    
    [srWebSocket open];
}

- (void) getCompressorStatus:(id)theData
{
    NSError *error = nil;
    NSData  *aData = [theData dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:aData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        
        // Check result.
        NSString *strResult = [dicData objectForKey:@"result"];
        NSLog(@"--> getCompressorStatus -> strResult = %@", strResult);
        if ([strResult isEqualToString:@"error"]) {
            [self showMessageHUD:[dicData objectForKey:@"message"]];
            return;
        }
        
        NSArray *records = [dicData objectForKey:@"data"];
        NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
        
        //
        for (NSDictionary *recordData in records) {
            NSLog(@"---------------------------------------");
            
            NSString *online = [recordData objectForKey:@"online"];
            NSLog(@"DATA --> online     = %@", online);
            [self.arrStatus addObject:online];
        }
        
        // 刷新数据
        [self.tableView reloadData];
        
    } else {
        NSLog(@"--> ERROR = %@", error.description);
    }
}


#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"--> YSJ_List -> Websocket Connected");
    
    //
    [srWebSocket send:self.dataForID];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"--> YSJ_List ->  :( Websocket Failed With Error:  %@", error);
    
    srWebSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"--> YSJ_List ->  Received =  %@", message);
    
    /*
    if ([message isKindOfClass:[NSString class]]) {
        NSLog(@"--> YSJ_List ->  Received =  NSString");
    } else if ([message isKindOfClass:[NSData class]]) {
        NSLog(@"--> YSJ_List ->  Received =  NSData");
    } else if (message == nil) {
        NSLog(@"--> YSJ_List ->  Received =  nil");
    } else {
        NSLog(@"--> YSJ_List ->  Received =  nothing...");
    }
    */
    
    // 解析数据
    [self getCompressorStatus:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"--> YSJ_List -> WebSocket closed");
    
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
