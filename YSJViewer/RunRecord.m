//
//  RunRecord.m -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-运行记录）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-12.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RunRecord.h"
#import "GlobalValue.h"

@interface RunRecord ()

@end

@implementation RunRecord


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
    
    self.myPickerData = [[NSArray alloc] initWithObjects:
                         @"1分钟", @"5分钟", @"10分钟", @"15分钟", @"30分钟", @"1小时", nil];
    self.myTimeJGData = [[NSArray alloc] initWithObjects:
                         @"1", @"5", @"10", @"15", @"30", @"60", nil];
    
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
    // 默认开始和结束时间
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd  00:00"];
    NSString *startTime  = [formatter stringFromDate:now];
    [formatter setDateFormat:@"yyyy-MM-dd  23:59"];
    NSString *endTime  = [formatter stringFromDate:now];
    
//    NSLog(@"myDate = %@", now);
    
    //
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"StartTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labStartTime  = (UILabel *)[cell viewWithTag:10];
            self.labStartTime.text = startTime;
            break;
        case 1:
            CellIdentifier = @"EndTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labEndTime    = (UILabel *)[cell viewWithTag:11];
            self.labEndTime.text = endTime;
            break;
        case 2:
            CellIdentifier = @"TimeJG";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labTimeJG     = (UILabel *)[cell viewWithTag:12];
            self.labTimeJG.text = @"1小时";
            break;
        default:
            break;
    }
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
//    self.labStartTime  = (UILabel *)[cell viewWithTag:10];
//    self.labEndTime    = (UILabel *)[cell viewWithTag:11];
//    self.labTimeJG     = (UILabel *)[cell viewWithTag:12];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    curLine = indexPath.row;
    
    if (curLine == 0 || curLine == 1) { // Start and End time select.
//        self.myDataView.hidden   = NO;
        self.myPickerView.hidden = YES;
        self.myDatePicker.hidden = NO;
        self.setCurrentTime.hidden = NO;
    } else {
//        self.myDataView.hidden   = NO;
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

- (IBAction)selectValue
{
    NSLog(@"selectValue");
    
//    self.myDataView.hidden   = YES;
    [self dataViewHidden];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
    
    if (curLine == 0) { // 开始时间
        NSString *startTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labStartTime.text = startTime;
    } else if (curLine == 1) { // 结束时间
        NSString *endTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labEndTime.text = endTime;
    } else if (curLine == 2) { // 时间间隔
        NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
        self.labTimeJG.text = [self.myPickerData objectAtIndex:selValue];
        self.myTimeJGData_SelValue = [self.myTimeJGData objectAtIndex:selValue];
    }
}

- (IBAction) currentTime
{
    NSLog(@"currentTime");
    
//    self.myDataView.hidden   = YES;
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
    
//    self.myDataView.hidden   = YES;
    [self dataViewHidden];
    
    if (curLine == 0) { // 开始时间
        self.labStartTime.text = @"设定";
    } else if (curLine == 1) { // 结束时间
        self.labEndTime.text = @"设定";
    } else if (curLine == 2) { // 时间间隔
        self.labTimeJG.text = @"设定";
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
    
    if ( [self.labTimeJG.text isEqualToString:@"设定"] ) {
        [self showMessageHUD:@"请设定间隔时间！"];
        return;
    }
    
    // Start query data.
//    [self api_RunReport];
    
    // 保持值，跳转页面。
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:self.labStartTime.text  forKey:@"StartTime"];
    [saveData setObject:self.labEndTime.text    forKey:@"EndTime"];
    [saveData setObject:self.myTimeJGData_SelValue forKey:@"TimeJG"];
    [saveData synchronize];
    
    //
    [self goTimeListScreen];
}

#pragma mark -  Go next screen.

- (void) goTimeListScreen
{
    // Go to TimeList screen.
    UIStoryboard *runRecordSB = [UIStoryboard storyboardWithName:@"RunRecordSB" bundle:nil];
    UIViewController *timelistVC     = [runRecordSB instantiateViewControllerWithIdentifier:@"RunRecord_TimeList"];
    
    [self.navigationController pushViewController:timelistVC animated:YES];
}

/*
- (void) api_RunReport
{
    NSLog(@"--> api_RunReport...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token    = [saveData  objectForKey:@"Token"];
    NSString *compId   = [saveData  objectForKey:@"YSJ_ID"];
    NSString *start    = self.labStartTime.text;
    NSString *end      = self.labEndTime.text;
    NSString *interval = self.myTimeJGData_SelValue;

    //--------------------
    NSString *nextPath = @"cis/mobile/runReport";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,    @"token",
                               compId,   @"compId",
                               start,    @"start",
                               end,      @"end",
                               interval, @"interval",
                               nil];
    
    NSLog(@"--> api_RunReport --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_RunReport -> RESULT = %@", str);
        
        [self getRunRecordData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_RunReport -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getRunRecordData:(id)theData
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
    NSMutableArray *arrTimeList = [[NSMutableArray alloc] init];
    NSMutableArray *arrItems    = [[NSMutableArray alloc] init];
    
    // 解析数据
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        //
        NSString *date = [recordData objectForKey:@"date"];
        NSLog(@"DATA --> date     = %@", date);
        [arrTimeList addObject:date];
       
        //
        NSArray *items = [recordData objectForKey:@"items"];
        NSLog(@"DATA --> items     = %@", items);
        [arrItems addObject:items];
    }
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:arrTimeList  forKey:@"arrTimeList"];
    [saveData setObject:arrItems     forKey:@"arrItems"];
    [saveData synchronize];
}
*/

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
