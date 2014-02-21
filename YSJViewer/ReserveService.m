//
//  ReserveService.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-预约服务）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-21.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "ReserveService.h"
#import "GlobalValue.h"

@interface ReserveService ()

@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (weak, nonatomic) IBOutlet UIView *myDataView;

@property (nonatomic) UITextField *txtDescription;
@property (nonatomic) UITextField *txtContacter;
@property (nonatomic) UITextField *txtTelephone;
@property (nonatomic) UILabel     *labExpectDate;
@property (nonatomic) UILabel     *labServiceType;
@property (nonatomic) UITextField *txtDetails;


@property (nonatomic) NSArray *myPickerData;
@property (nonatomic) NSArray *myTimeJGData;
@property (nonatomic) NSString *myTimeJGData_SelValue;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation ReserveService

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
                         @"故障排除", @"现场培训", @"上海培训", @"常规保养",
                         @"整机保养", @"巡检", @"零件销售", @"服务销售",
                         @"客户考察", @"其他", nil];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    self.txtDescription.delegate = self;
    self.txtContacter.delegate   = self;
    self.txtTelephone.delegate   = self;
    self.txtDetails.delegate     = self;
    
    // Background image - Single Tap
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard_RS)];
//    [self.view addGestureRecognizer:singleTap];
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
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // 默认期望服务时间
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strExpectDate  = [formatter stringFromDate:now];
    
    //
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"description";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.txtDescription  = (UITextField *)[cell viewWithTag:10];
            break;
        case 1:
            CellIdentifier = @"serviceType";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labServiceType  = (UILabel *)[cell viewWithTag:15];
            break;
        case 2:
            CellIdentifier = @"contacter";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.txtContacter  = (UITextField *)[cell viewWithTag:11];
            break;
        case 3:
            CellIdentifier = @"telephone";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.txtTelephone  = (UITextField *)[cell viewWithTag:12];
            break;
        case 4:
            CellIdentifier = @"expectDate";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labExpectDate = (UILabel *)[cell viewWithTag:13];
            self.labExpectDate.text = strExpectDate;
            break;
        case 5:
            CellIdentifier = @"details";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.txtDetails  = (UITextField *)[cell viewWithTag:14];
            break;
        default:
            break;
    }
    
    //
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    curLine = indexPath.row;
    NSLog(@"curLine = %d", curLine);
    
    if (curLine == 1) { // 服务类型
        self.myPickerView.hidden = NO;
        self.myDatePicker.hidden = YES;
        
    } else if (curLine == 4) { // 期望服务时间
        self.myPickerView.hidden = YES;
        self.myDatePicker.hidden = NO;
    }
    
    // myDataView 的位置是 Y = 378 （为了做动画，初始 Y = 570）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myDataView.frame;
                         testFrame.origin.y = 378;
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
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    if (curLine == 1) { // 服务类型
        NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
        self.labServiceType.text = [self.myPickerData objectAtIndex:selValue];
//        self.myTimeJGData_SelValue = [self.myTimeJGData objectAtIndex:selValue];
        
    } else if (curLine == 4) { // 期望服务时间
        NSString *expectDate  = [formatter stringFromDate:self.myDatePicker.date];
        self.labExpectDate.text = expectDate;
        
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
    
    /*
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
     */
}


#pragma mark - Keyboad Method.

- (void) hideKeyboard_RS {
    [self.txtDetails     resignFirstResponder];
    [self.txtTelephone   resignFirstResponder];
    [self.txtContacter   resignFirstResponder];
    [self.txtDescription resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField.tag == 10) {  //
//        [self.txtContacter becomeFirstResponder];
//    } else if (textField.tag == 11) { //
//        [self.txtTelephone becomeFirstResponder];
//    } else if (textField.tag == 12) { //
//        [self.txtDetails becomeFirstResponder];
//    } else if (textField.tag == 14) { //
//        [textField resignFirstResponder];
//    }
    
    [self hideKeyboard_RS];
    
    return YES;
}

@end
