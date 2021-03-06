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
    
    // Get Server Address.
//    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
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
    NSLog(@"clickButtonAtIndex: %ld", (long)buttonIndex);
    
    if (buttonIndex == 0) { // 取消
        // Nothing.
    } else if (buttonIndex == 1) { // 确定
        // Save data to cache.
        NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
        NSString *compId = [saveData  objectForKey:@"YSJ_ID"];
        
        [saveData setObject:self.myJCLData_SelValue forKey:@"ALC_iId"];       //检测量编号
        [saveData setObject:compId                 forKey:@"ALARM_COMP_ID"]; // 压缩机ID
        [saveData setObject:self.labJCL.text       forKey:@"ALC_NAME"];      // 检测量名称
        [saveData setObject:self.labStartTime.text forKey:@"ALC_START_TIME"];
        [saveData setObject:self.labEndTime.text   forKey:@"ALC_END_TIME"];
        [saveData synchronize];
        
        //
        [self go_ALC_LineChart];   // 报警曲线显示
    }
}


#pragma mark -  Go next screen.

- (void) go_ALC_LineChart
{
    // Go to Home screen.
    UIStoryboard *alc = [UIStoryboard storyboardWithName:@"Alarm_LineChart" bundle:nil];
    UIViewController *homeVC     = [alc instantiateViewControllerWithIdentifier:@"Alarm_LineChart"];
    
    [self.navigationController pushViewController:homeVC animated:YES];
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
