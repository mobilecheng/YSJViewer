//
//  AlarmInfoDetail.m -- 主菜单 --> 报警信息 --> 报警信息详情
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-9.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "AlarmInfoDetail.h"
#import "GlobalValue.h"

@interface AlarmInfoDetail ()

@property (weak, nonatomic) IBOutlet UILabel *labCompName;
@property (weak, nonatomic) IBOutlet UILabel *labAlarmTime;
@property (weak, nonatomic) IBOutlet UILabel *labAlarmInfo;
@property (weak, nonatomic) IBOutlet UITableView *tabDetail;

@property (nonatomic) NSMutableArray *arrDetailName;  
@property (nonatomic) NSMutableArray *arrDetailValue;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation AlarmInfoDetail

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
    
    // get data.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.labCompName.text  = [saveData stringForKey:@"ALARM_NAME"];
    self.labAlarmInfo.text = [saveData stringForKey:@"ALARM_INFO"];
    self.labAlarmTime.text = [saveData stringForKey:@"ALARM_TIME"];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tabDetail];
    
    //
    [self api_GetAlarmDetail];
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
    return self.arrDetailName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlarmInfoDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labDetail_name = (UILabel *)[cell viewWithTag:10];
    labDetail_name.text = [self.arrDetailName objectAtIndex:indexPath.row];
    
    UILabel *labDetail_value = (UILabel *)[cell viewWithTag:11];
    labDetail_value.text = [self.arrDetailValue objectAtIndex:indexPath.row];
    
    //
    return cell;
}

#pragma mark -  API call.

- (void) api_GetAlarmDetail
{
    NSLog(@"--> api_GetAlarmDetail...");
    
    //
//    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token   = [saveData objectForKey:@"Token"];
    NSString *alarmID = [saveData stringForKey:@"ALARM_ID"];
    NSLog(@"--> ALARM_ID = %@", alarmID);
//    alarmID = @"4406"; // temp data.
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getAlarmDetail";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,   @"token",
                               alarmID, @"id",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetAlarmDetail -> RESULT = %@", str);
        
        [self getAlarmDetailData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetAlarmData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void) getAlarmDetailData:(id)theData
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
        [self showMessageHUD:@"没有报警详情数据."];
        return;
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        NSLog(@"DATA --> name     = %@", [recordData objectForKey:@"name"]);
        [self.arrDetailName addObject:[recordData objectForKey:@"name"]];
        
        //
        NSString *unit  = [recordData objectForKey:@"unit"];
        NSString *value = [recordData objectForKey:@"value"];
        value = [NSString stringWithFormat:@"%@ %@", value, unit];
        NSLog(@"DATA --> value    = %@", value);
        [self.arrDetailValue addObject:value];
    }
    
    // 刷新数据
    [self.tabDetail reloadData];
}


#pragma mark -  Init Data.

- (void)initData
{
    self.arrDetailName  = [[NSMutableArray alloc] init];
    self.arrDetailValue = [[NSMutableArray alloc] init];
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
