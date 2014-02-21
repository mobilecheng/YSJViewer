//
//  HistoryData.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-历史数据）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-11.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "HistoryData.h"
#import "GlobalValue.h"

@interface HistoryData ()

//@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation HistoryData

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
    
    // 开始构造数值 - 0
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.myJCLData    = [saveData objectForKey:@"YSJ_Items_iID"];
    self.myPickerData = [saveData objectForKey:@"YSJ_Items_name"];
//    NSLog(@"RRT -->  | tempID   = %@", tempID);
//    NSLog(@"RRT -->  | tempName = %@", tempName);
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"历史数据数据量很大，请尽量在免费WIFI下使用";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"StartTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labStartTime  = (UILabel *)[cell viewWithTag:10];
            break;
        case 1:
            CellIdentifier = @"EndTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labEndTime    = (UILabel *)[cell viewWithTag:11];
            break;
        case 2:
            CellIdentifier = @"JCL";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labJCL     = (UILabel *)[cell viewWithTag:12];
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    curLine = indexPath.row;
    
    if (curLine == 0 || curLine == 1) { // Start and End time select.
        self.myPickerView.hidden = YES;
        self.myDatePicker.hidden = NO;
        self.setCurrentTime.hidden = NO;
    } else {
        self.myPickerView.hidden = NO;
        self.myDatePicker.hidden = YES;
        self.setCurrentTime.hidden = YES;
    }
    
    // myDataView 的位置是 Y = 305 （为了做动画，初始 Y = 570）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myDataView.frame;
                         testFrame.origin.y = 305;
                         self.myDataView.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.myPickerData count];
}

#pragma mark - Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row             forComponent:(NSInteger)component
{
    return [self.myPickerData objectAtIndex:row];
}

#pragma mark -  IBAction Methods.

- (IBAction) selectValue
{
    NSLog(@"selectValue");
    
    [self dataViewHidden];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
    
    if (curLine == 0) { // 开始时间
        NSString *startTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labStartTime.text = startTime;
    } else if (curLine == 1) { // 结束时间
        NSString *endTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labEndTime.text = endTime;
    } else if (curLine == 2) { // 检测量
        NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
        self.labJCL.text = [self.myPickerData objectAtIndex:selValue];
        self.myJCLData_SelValue = [self.myJCLData objectAtIndex:selValue];
    }
}

- (IBAction) currentTime
{
    NSLog(@"currentTime");
    
    [self dataViewHidden];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
    
    NSDate *now = [NSDate date];
    NSLog(@"myDate = %@", now);
    
    if (curLine == 0) { // 开始时间
        NSString *startTime  = [formatter stringFromDate:now];
        self.labStartTime.text = startTime;
    } else if (curLine == 1) { // 结束时间
        NSString *endTime  = [formatter stringFromDate:now];
        self.labEndTime.text = endTime;
    }
}


- (IBAction) clearTime
{
    NSLog(@"clearTime");
    
    [self dataViewHidden];
    
    if (curLine == 0) { // 开始时间
        self.labStartTime.text = @"设定";
    } else if (curLine == 1) { // 结束时间
        self.labEndTime.text = @"设定";
    } else if (curLine == 2) { // 检测量
        self.labJCL.text = @"设定";
    }
}

- (IBAction) dataViewHidden
{
    // myDataView 的位置是 Y = 305 （为了做动画，初始 Y = 570）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myDataView.frame;
                         testFrame.origin.y = 570;
                         self.myDataView.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (IBAction) queryData
{
    NSLog(@"queryData");
    
    // Check
    if ( [self.labStartTime.text isEqualToString:@"设定"] ) {
        [self showMessageHUD:@"请设定开始时间！"];
        return;
    }
    
    if ( [self.labEndTime.text isEqualToString:@"设定"] ) {
        [self showMessageHUD:@"请设定结束时间！"];
        return;
    }
    
    if ( [self.labJCL.text isEqualToString:@"设定"] ) {
        [self showMessageHUD:@"请设定检测量！"];
        return;
    }
    
    // 提示
    NSString *strMessage = @"历史数据数据量很大，请尽量在免费WIFI下使用，确定使用？";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:strMessage
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

//根据被点击按钮的索引处理点击事件
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickButtonAtIndex: %d", buttonIndex);
    
    if (buttonIndex == 0) { // 取消
        // Nothing.
    } else if (buttonIndex == 1) { // 确定
        // 保持值，跳转页面。
        // Save data to cache.
        /*
        NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
        [saveData setObject:self.labStartTime.text  forKey:@"StartTime"];
        [saveData setObject:self.labEndTime.text    forKey:@"EndTime"];
        [saveData setObject:self.myTimeJGData_SelValue forKey:@"TimeJG"];
        [saveData synchronize];
        
        //
        [self goTimeListScreen];
         */
        
        // API call.
        [self api_GetHistoryData];
    }
}

#pragma mark -  API call.

- (void) api_GetHistoryData
{
    NSLog(@"--> api_GetHistoryData...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token  = [saveData objectForKey:@"Token"];
    NSString *compId = [saveData objectForKey:@"YSJ_ID"];
    NSString *iId    = self.myJCLData_SelValue; // 检测量编号
    NSString *start  = self.labStartTime.text;
    NSString *end    = self.labEndTime.text;
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getHistoryData";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,    @"token",
                               compId,   @"compId",
                               iId,      @"iId",
                               start,    @"start",
                               end,      @"end",
                               nil];
    
    NSLog(@"--> api_GetHistoryData --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetHistoryData -> RESULT = %@", str);
        
//        [self getRunRecordData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetHistoryData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getHistoryData:(id)theData
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
//        [self.arrTimeList addObject:date];
        
        //
        NSArray *items = [recordData objectForKey:@"items"];
        NSLog(@"DATA --> items    = %@", items);
//        [self.arrItems addObject:items];
    }
    
    // 刷新数据
//    [self.tableView reloadData];
}


#pragma mark -  Go next screen.

- (void) goTimeListScreen
{
    // Go to TimeList screen.
    UIStoryboard *runRecordSB = [UIStoryboard storyboardWithName:@"RunRecordSB" bundle:nil];
    UIViewController *timelistVC     = [runRecordSB instantiateViewControllerWithIdentifier:@"RunRecord_TimeList"];
    
    [self.navigationController pushViewController:timelistVC animated:YES];
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
