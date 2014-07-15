//
//  ViewController.m -- 主菜单页面
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "Home.h"
#import "GlobalValue.h"

@interface Home ()

@property (nonatomic) NSMutableArray *arrYSJ_ID;   // 压缩机 ID
@property (nonatomic) NSMutableArray *arrModel;  // 压缩机型号
@property (nonatomic) NSMutableArray *arrName;   // 压缩机名字
@property (nonatomic) NSMutableArray *arrCSN;   // 压缩机编号

@property (nonatomic) MKNetworkEngine *engine;

@property (nonatomic) NSString *dataForID;

@end

@implementation Home

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //
    [self initData];
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    [self api_CompressorList];
    
    // for test noti.
    // Query Now.
    [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(api_GetStock_forLocalNoti) userInfo:nil repeats:NO];
    
    
    // 定期查询库存 - 时间间隔根据设置界面的数值（1，2，3，7，15天），测试目的，改为120秒。
//    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSInteger days = [saveData integerForKey:@"StockQueryDays"];
    NSLog(@"StockQueryDays = %d", days);
    
    //
    long seconds;
    if (days == 0) {
        return;
    } else {
        seconds = days * 24 * 60 * 60;
        NSLog(@"StockQuery Seconds = %ld", seconds);
    }
    
//    [NSTimer scheduledTimerWithTimeInterval:(seconds) target:self selector:@selector(api_GetStock_forLocalNoti) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:(120000.0) target:self selector:@selector(api_GetStock_forLocalNoti) userInfo:nil repeats:YES];
     
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

#pragma mark -  FOR LOCAL NOTI.


- (void) api_GetStock_forLocalNoti
{
    NSLog(@"--> api_GetStock_forLocalNoti...");
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getStock";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,  @"token", nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetStock_forLocalNoti -> RESULT = %@", str);
        
        [self getStockData_forLocalNoti:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetStock_forLocalNoti -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getStockData_forLocalNoti:(id)theData
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
//        [self showMessageHUD:[dicData objectForKey:@"message"]];
        NSLog(@"--> ERROR = %@", [dicData objectForKey:@"message"]);
        return;
    }
    
    NSArray *records = [dicData objectForKey:@"records"];
    
    // 6-17 add
    if (records.count == 0) {
        return; // 无库存数据
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        // 零件名字
        NSString *theName = [recordData objectForKey:@"name"];
        NSLog(@"DATA --> 零件名字     = %@", theName);
        
        // 零件单位
//        NSString *unit = [recordData objectForKey:@"unit"];
//        NSLog(@"DATA --> 零件单位     = %@", unit);
        
        // 用于库存不足的判断
        NSString *qtyStock  = [recordData objectForKey:@"qty"];
        NSString *safeStock = [recordData objectForKey:@"safeStock"];
        if ([qtyStock intValue] < [safeStock intValue]) { // 库存不足
            NSString *notiBody = [NSString stringWithFormat:@"%@ 库存不足!", theName];
            [self addLocalNoti:notiBody];
        } else {
            // 库存够
        }
        
        // 目前库存数量
//        qtyStock = [NSString stringWithFormat:@"%@%@", qtyStock, unit];
//        NSLog(@"DATA --> 目前库存数量     = %@", qtyStock);
        
        // 安全库存数量
//        safeStock = [NSString stringWithFormat:@"%@%@", safeStock, unit];
//        NSLog(@"DATA --> 安全库存数量     = %@", safeStock);
    }
    
}

// for noti test
- (void) addLocalNoti:(NSString *)strAlertBody
{
    // 创建一个本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置1秒之后
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:1];
    
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = pushDate;
        // 设置时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
//        notification.repeatInterval = kCFCalendarUnitDay;
        notification.repeatInterval = 0;
        
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = strAlertBody;
        
        //显示在icon上的红色圈中的数子
        //        notification.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用
//        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
//        notification.userInfo = info;
        
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
        
    }
}

#pragma mark -  Init Data.

- (void) initData
{
    self.arrName   = [[NSMutableArray alloc] init];
    self.arrModel  = [[NSMutableArray alloc] init];
    self.arrYSJ_ID = [[NSMutableArray alloc] init];
    self.arrCSN    = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

- (void) api_CompressorList
{
    NSLog(@"--> Home --> apiCompressorList");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getCompressorList";
    
    /*
    NSDictionary *account = [saveData objectForKey:@"Account"];
    NSString *serviceCode = [account  objectForKey:@"servicecode"];
    NSLog(@"--> serviceCode = %@", serviceCode);
    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/getCompressorList", serviceCode];
    */
    
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
        NSLog(@"--> Home --> apiCompressorList -> RESULT = %@", str);
        
        [self getCompressorList:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> Home --> apiCompressorList -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) getCompressorList:(id)theData
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
        //            [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    NSArray *records = [dicData objectForKey:@"records"];
    NSLog(@"HOME--> IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    // 构造参数，用于订阅压缩机报警查询
    NSMutableArray *tempIDInfo = [[NSMutableArray alloc] init];
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        // 压缩机ID
        NSLog(@"DATA --> 压缩机-id = %@", [recordData objectForKey:@"id"]);
        [self.arrYSJ_ID addObject:[recordData objectForKey:@"id"]];
        
        // 压缩机名称 - 5-26 update.
        if ([recordData objectForKey:@"alias"] == [NSNull null]) {
            NSLog(@"DATA --> alias   = NULL");
            [self.arrName addObject:[recordData objectForKey:@"cSN"]];
        } else {
            NSLog(@"DATA --> alias   = %@", [recordData objectForKey:@"alias"]);
            [self.arrName addObject:[recordData objectForKey:@"alias"]];
        }
        
        // 压缩机型号
        NSLog(@"DATA --> model   = %@", [recordData objectForKey:@"model"]);
        [self.arrModel addObject:[recordData objectForKey:@"model"]];
        
        // 压缩机编号
        NSLog(@"DATA --> cSN     = %@", [recordData objectForKey:@"cSN"]);
        [self.arrCSN addObject:[recordData objectForKey:@"cSN"]];
        
        //------- 5-26 update.
        NSString *cId = [recordData objectForKey:@"cId"];
        NSLog(@"DATA --> cId     = %@", cId);
        
        NSString *sID = [recordData objectForKey:@"sId"];
        NSLog(@"DATA --> sId     = %@", sID);
        
        if ( ([recordData objectForKey:@"cId"] == [NSNull null]) ||
            ([recordData objectForKey:@"sId"] == [NSNull null])    ) {
            
            // do nothing.
        } else {
            // 构造参数，用于订阅压缩机报警查询
            NSDictionary *idInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    sID, @"sId", cId, @"cId", nil];
            [tempIDInfo addObject:idInfo];
        }
    }
    
    
    // 构造参数，用于订阅信息查询
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            tempIDInfo, @"data", nil];
    self.dataForID = [params jsonEncodedKeyValueString];
    NSLog(@"--> 参数用于订阅压缩机报警查询 = %@", self.dataForID);
    
    // 订阅压缩机报警
    [self api_GetAlarmdata];
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:self.arrYSJ_ID forKey:@"HOME_YSJ_ID"];
    [saveData setObject:self.arrName   forKey:@"HOME_YSJ_NAME"];
    [saveData setObject:self.arrModel  forKey:@"HOME_YSJ_MODEL"];
    [saveData setObject:self.arrCSN    forKey:@"HOME_YSJ_CSN"];
    [saveData synchronize];
}

// 订阅压缩机报警
- (void) api_GetAlarmdata
{
    NSLog(@"--> HOME - api_GetAlarmdata -> Opening WebSocket Connection...");
    
    srWebSocket.delegate = nil;
    [srWebSocket close];
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"ws://%@:3180/getAlarmdata", [saveData stringForKey:@"ServerAddress"]];
    
//    NSString *url = @"ws://117.34.92.46:3182/getAlarmdata";
    
    srWebSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    srWebSocket.delegate = self;
    
    [srWebSocket open];
}

// 解析订阅压缩机报警数据
- (void) getAlarmdata:(id)theData
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
    NSLog(@"--> getAlarmdata -> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
//        [self showMessageHUD:[dicData objectForKey:@"message"]];
        NSLog(@"--> ERROR = %@", [dicData objectForKey:@"message"]);
        return;
    }
    
    // 解析数据
    NSDictionary *records = [dicData objectForKey:@"data"];
//    NSLog(@"--> COUNT = %d", [records count]);
    if (records.count == 0) {
//        [self showMessageHUD:@"没有实时数据."];
        NSLog(@"--> ERROR = 没有订阅压缩机报警数据");
        return;
    }
    
    // itemName
    NSString *notiBody = [records objectForKey:@"alarmStr"];
    notiBody = [notiBody substringFromIndex:25];
    NSLog(@"DATA --> notiBody = %@", notiBody);

    //
    [self addLocalNoti:notiBody];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"--> Home -> Websocket Connected");
    
    //
    [srWebSocket send:self.dataForID];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@"--> Home ->  :( Websocket Failed With Error:  %@", error);
    
    srWebSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"--> Home ->  Received =  %@", message);
    
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
    [self getAlarmdata:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"--> Home -> WebSocket closed");
    
    srWebSocket = nil;
}


@end
