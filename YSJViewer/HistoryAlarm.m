//
//  HistoryAlarm.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-历史报警）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-25.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "HistoryAlarm.h"
#import "GlobalValue.h"

@interface HistoryAlarm ()

@property (weak, nonatomic) IBOutlet UILabel *labCompName;
@property (weak, nonatomic) IBOutlet UITableView *tvAlarmInfo;

@property (nonatomic) NSMutableArray *arrName;       // 压缩机名字
@property (nonatomic) NSMutableArray *arrAlarmInfo;  // 压缩机报警信息
@property (nonatomic) NSMutableArray *arrModel;      // 压缩机型号
@property (nonatomic) NSMutableArray *arrTime;       // 压缩机报警时间
@property (nonatomic) NSMutableArray *arrAlarmID;    // 报警记录id

@property (nonatomic) NSArray *tempID;   // temp data.
@property (nonatomic) NSArray *tempName; // temp data.
@property (nonatomic) NSArray *tempModel; // temp data.

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation HistoryAlarm

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
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.labCompName.text = [saveData stringForKey:@"YSJ_NAME"];
    
    // Get Server Address.
//    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tvAlarmInfo];
    
    //
    [self api_GetAlarmData];
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
    return self.arrAlarmInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OneCompAlarmInfo_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // 压缩机报警信息
    UILabel *labAlarmInfo = (UILabel *)[cell viewWithTag:10];
    labAlarmInfo.text = [self.arrAlarmInfo objectAtIndex:indexPath.row];
    
    // 压缩机报警时间
    UILabel *labTime = (UILabel *)[cell viewWithTag:11];
    labTime.text = [self.arrTime objectAtIndex:indexPath.row];
    
    //
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name  = [self.arrName      objectAtIndex:indexPath.row];  // 压缩机名字
    NSString *info  = [self.arrAlarmInfo objectAtIndex:indexPath.row];  //
    NSString *time  = [self.arrTime      objectAtIndex:indexPath.row];
    NSString *aID   = [self.arrAlarmID   objectAtIndex:indexPath.row];
    //    NSLog(@"YSJ name = %@ | ID = %@ | CID = %@ | SID = %@", name, ysjID, cid, sid);
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 5-5 add
    NSString *compId = [saveData  objectForKey:@"YSJ_ID"];
    [saveData setObject:compId    forKey:@"ALARM_COMP_ID"]; // 压缩机ID
    
    [saveData setObject:name  forKey:@"ALARM_NAME"];
    [saveData setObject:info  forKey:@"ALARM_INFO"];
    [saveData setObject:time  forKey:@"ALARM_TIME"];
    [saveData setObject:aID   forKey:@"ALARM_ID"];
    
    [saveData synchronize];
}


#pragma mark -  Init Data.

- (void)initData
{
    self.arrName      = [[NSMutableArray alloc] init];
    self.arrAlarmInfo = [[NSMutableArray alloc] init];
    self.arrModel     = [[NSMutableArray alloc] init];
    self.arrTime      = [[NSMutableArray alloc] init];
    self.arrAlarmID   = [[NSMutableArray alloc] init];
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.tempID    = [saveData objectForKey:@"HOME_YSJ_ID"];
    self.tempName  = [saveData objectForKey:@"HOME_YSJ_NAME"];
    self.tempModel = [saveData objectForKey:@"HOME_YSJ_MODEL"];
}

#pragma mark -  API call.

- (void) api_GetAlarmData
{
    NSLog(@"--> HA_api_GetAlarmData...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *compId = [saveData objectForKey:@"YSJ_ID"];
    NSString *max    = @"100";
    NSString *offset = @"0";
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getAlarm";
    
    /*
    NSDictionary *account = [saveData objectForKey:@"Account"];
    NSString *serviceCode = [account  objectForKey:@"servicecode"];
    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/getAlarm", serviceCode];
    */
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,  @"token",
                               compId, @"compId",
                               max,    @"max",
                               offset, @"offset",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> HA_api_GetAlarmData -> RESULT = %@", str);
        
        [self getAlarmData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> HA_api_GetAlarmData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getAlarmData:(id)theData
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
        [self showMessageHUD:@"没有历史报警数据."];
        return;
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    //
    for (NSDictionary *recordData in records) {
        //        NSLog(@"---------------------------------------");
        
        // 通过压缩机ID取名称和型号
        NSString *compId = [recordData objectForKey:@"compId"];
        //        NSLog(@"DATA --> compId     = %@", compId);
        [self getCompNameAndModel:[compId intValue]];
        
        // 报警信息
        //        NSLog(@"DATA --> message     = %@", [recordData objectForKey:@"message"]);
        [self.arrAlarmInfo addObject:[recordData objectForKey:@"message"]];
        
        // 报警时间
        //        NSLog(@"DATA --> date   = %@", [recordData objectForKey:@"date"]);
        [self.arrTime addObject:[recordData objectForKey:@"date"]];
        
        // 报警ID
        //        NSLog(@"DATA --> arrAlarmID   = %@", [recordData objectForKey:@"id"]);
        [self.arrAlarmID addObject:[recordData objectForKey:@"id"]];
    }
    
    // 刷新数据
    [self.tvAlarmInfo reloadData];
}

- (void) getCompNameAndModel:(int)compId
{
    for (int i = 0; i < self.tempID.count; i++) {
        NSString *strID = self.tempID[i];
        //        NSLog(@"DATA --> strID     = %@", strID);
        if ( compId == [strID intValue] ) {
            [self.arrName  addObject:self.tempName[i]];
            [self.arrModel addObject:self.tempModel[i]];
            return;
        }
    }
}

#pragma mark -  IBAction Methods.

- (IBAction) refreshData
{
    NSLog(@"refreshAlarmData");
    
    [self.arrName       removeAllObjects];
    [self.arrAlarmInfo  removeAllObjects];
    [self.arrModel      removeAllObjects];
    [self.arrTime       removeAllObjects];
    [self.arrAlarmID    removeAllObjects];
    
    [self.tvAlarmInfo reloadData];
    
    [self api_GetAlarmData];
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
