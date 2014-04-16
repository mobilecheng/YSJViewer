//
//  StockQuery.m -- 主菜单 --> 库存查看
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-9.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "StockQuery.h"
#import "GlobalValue.h"

@interface StockQuery ()

@property (nonatomic) NSMutableArray *arrName;       // 零件名字
@property (nonatomic) NSMutableArray *arrQtyStock;  // 目前库存数量
@property (nonatomic) NSMutableArray *arrSafeStock;  // 安全库存数量
@property (nonatomic) NSMutableArray *arrUnit;      // 零件单位
@property (nonatomic) NSMutableArray *arrCheck;      // 用于库存不足的判断

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation StockQuery

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
    [self api_GetStock];
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
    return self.arrName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Stock_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // 零件名字
    UILabel *labName = (UILabel *)[cell viewWithTag:101];
    labName.text = [self.arrName objectAtIndex:indexPath.row];
    
    // 目前库存数量
    UILabel *labQtyStock = (UILabel *)[cell viewWithTag:104];
    labQtyStock.text = [self.arrQtyStock objectAtIndex:indexPath.row];
    
    // 安全库存数量
    UILabel *labSafeStock = (UILabel *)[cell viewWithTag:106];
    labSafeStock.text = [self.arrSafeStock objectAtIndex:indexPath.row];
    
    // 库存不足和图标
    UILabel *labStockShort = (UILabel *)[cell viewWithTag:102];
    UIImageView *imgIcon   = (UIImageView *)[cell viewWithTag:100];
    NSString *value = [self.arrCheck objectAtIndex:indexPath.row];
    if ([value isEqualToString:@"yes"]) { // 库存不足
        labStockShort.hidden = NO;
        imgIcon.image = [UIImage imageNamed:@"inventory_supply_indicator"];
        labName.textColor = [UIColor redColor];
        labQtyStock.textColor = [UIColor redColor];
    } else if ([value isEqualToString:@"no"]) { // 库存够
        labStockShort.hidden = YES;
        imgIcon.image = [UIImage imageNamed:@"inventory_list_indicator"];
        labName.textColor = [UIColor blackColor];
        labQtyStock.textColor = [UIColor blackColor];
    }
    
    //
    return cell;
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrName      = [[NSMutableArray alloc] init];
    self.arrQtyStock  = [[NSMutableArray alloc] init];
    self.arrSafeStock = [[NSMutableArray alloc] init];
    self.arrUnit      = [[NSMutableArray alloc] init];
    self.arrCheck     = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

- (void) api_GetStock
{
    NSLog(@"--> api_GetStock...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
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
        NSLog(@"--> api_GetStock -> RESULT = %@", str);
        
        [self getStockData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetStock -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getStockData:(id)theData
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
        
        // 零件名字
        NSString *theName = [recordData objectForKey:@"name"];
        NSLog(@"DATA --> 零件名字     = %@", theName);
        [self.arrName addObject:theName];
        
        // 零件单位
        NSString *unit = [recordData objectForKey:@"unit"];
        NSLog(@"DATA --> 零件单位     = %@", unit);
        
        // 用于库存不足的判断
        NSString *qtyStock  = [recordData objectForKey:@"qty"];
        NSString *safeStock = [recordData objectForKey:@"safeStock"];
        if ([qtyStock intValue] < [safeStock intValue]) { // 库存不足
            [self.arrCheck addObject:@"yes"];
            
            // for local noti.
            NSString *notiBody = [NSString stringWithFormat:@"%@ 库存不足!", theName];
            [self addLocalNoti:notiBody];
        } else {
            [self.arrCheck addObject:@"no"];
        }
        
        // 目前库存数量
        qtyStock = [NSString stringWithFormat:@"%@%@", qtyStock, unit];
        NSLog(@"DATA --> 目前库存数量     = %@", qtyStock);
        [self.arrQtyStock addObject:qtyStock];
        
        // 安全库存数量
        safeStock = [NSString stringWithFormat:@"%@%@", safeStock, unit];
        NSLog(@"DATA --> 安全库存数量     = %@", safeStock);
        [self.arrSafeStock addObject:safeStock];
    }
    
    // 刷新数据
    [self.tableView reloadData];
}

#pragma mark -  IBAction Methods.

- (IBAction) refreshData
{
    NSLog(@"refreshStockData");
    
    [self.arrName      removeAllObjects];
    [self.arrQtyStock  removeAllObjects];
    [self.arrSafeStock removeAllObjects];
    [self.arrUnit      removeAllObjects];
    [self.arrCheck     removeAllObjects];
    
    [self.tableView reloadData];
    
    [self api_GetStock];
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

#pragma mark -  FOR LOCAL NOTI.

// for noti test
- (void) addLocalNoti:(NSString *)strAlertBody
{
    // 创建一个本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    //设置1秒之后
    NSDate *pushDate = [NSDate dateWithTimeIntervalSinceNow:3];
    
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
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
        notification.userInfo = info;
        //添加推送到UIApplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:notification];
        
    }
}
@end
