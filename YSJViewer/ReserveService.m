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
@property (weak, nonatomic) IBOutlet UILabel *labTopTitle;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

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
    
    //
//    self.myPickerData = [[NSArray alloc] initWithObjects:
//                         @"故障排除", @"现场培训", @"上海培训", @"常规保养",
//                         @"整机保养", @"巡检", @"零件销售", @"服务销售",
//                         @"客户考察", @"其他", nil];
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
//    self.txtDescription.delegate = self;
//    self.txtContacter.delegate   = self;
//    self.txtTelephone.delegate   = self;
//    self.txtDetails.delegate     = self;
    
    //   - Single Tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard_RS)];
    [self.labTopTitle addGestureRecognizer:singleTap];
    
    //
//    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *name  = [saveData stringForKey:@"YSJ_NAME"];
    NSString *csn   = [saveData stringForKey:@"YSJ_CSN"];
    
    NSLog(@"name = %@ | csn = %@", name, csn);
    
    if ( name != nil ) {
        NSString *title = [NSString stringWithFormat:@"%@  %@", name, csn];
        self.labTopTitle.text = title;
    } else {
        self.labTopTitle.text = @"";
    }
    
    // 获取服务类型
    [self api_GetServiceType];
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
    self.txtDescription.delegate = self;
    self.txtContacter.delegate   = self;
    self.txtTelephone.delegate   = self;
    self.txtDetails.delegate     = self;
    
    //
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    [self hideKeyboard_RS];
    
    //
    curLine = indexPath.row;
    NSLog(@"curLine = %d", curLine);
    
    if (curLine == 1) { // 服务类型
        self.myPickerView.hidden = NO;
        self.myDatePicker.hidden = YES;
        [self dataViewOpen];
    } else if (curLine == 4) { // 期望服务时间
        self.myPickerView.hidden = YES;
        self.myDatePicker.hidden = NO;
        [self dataViewOpen];
    }
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

- (void) dataViewOpen
{
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

- (IBAction) dataViewHidden
{
    // myDataView 的位置是 Y = 378 （为了做动画，初始 Y = 570）
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

/**
 * @brief  107: 原来位置  60: 移动位置
 */
- (void) moveTableView:(CGFloat)yValue
{
    // TableView 的位置是 Y = 107 （为了做动画， Y = 60）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myTableView.frame;
                         testFrame.origin.y = yValue;
                         self.myTableView.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (IBAction) saveServiceRequest
{
    NSLog(@"saveServiceRequest");
    
    // Check the desciption that NO NULL.
    NSString *strDescription = [self.txtDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strDescription isEqualToString:@""]) { //
        [self showMessageHUD:@"请输入描述信息."];
        [self.txtDescription becomeFirstResponder];
        return;
    } else {
        if (strDescription.length > 100) {
            [self showMessageHUD:@"描述信息不能超过100个字符."];
            [self.txtDescription becomeFirstResponder];
            return;
        }
    }
    
    // Check the ServiceType that NO NULL.
    NSString *strServiceType = [self.labServiceType.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strServiceType isEqualToString:@""]) { //
        [self showMessageHUD:@"服务申请类型必须选择."];
        return;
    }
    
    // Check the Contacter that NO NULL.
    NSString *strContacter = [self.txtContacter.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strContacter isEqualToString:@""]) { //
        [self showMessageHUD:@"请输入联系人."];
        [self.txtContacter becomeFirstResponder];
        return;
    } else {
        if (strContacter.length > 10) {
            [self showMessageHUD:@"联系人不能超过10个字符."];
            [self.txtContacter becomeFirstResponder];
            return;
        }
    }
    
    // Check the Telephone that NO NULL.
    NSString *strTelephone = [self.txtTelephone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strTelephone isEqualToString:@""]) { //
        [self showMessageHUD:@"请输入联系电话."];
        [self.txtTelephone becomeFirstResponder];
        return;
    } else {
        if (strTelephone.length > 30) {
            [self showMessageHUD:@"联系电话不能超过30个字符."];
            [self.txtTelephone becomeFirstResponder];
            return;
        }
    }
    
    // Check the ExpectDate that NO NULL.
    NSString *strExpectDate = [self.labExpectDate.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strExpectDate isEqualToString:@""]) { //
        [self showMessageHUD:@"期望服务时间不能为空."];
        return;
    }
    
    // Check the Details.
    NSString *strDetails = [self.txtDetails.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strDetails.length > 200) {
        [self showMessageHUD:@"详细信息不能超过200个字符."];
        [self.txtDetails becomeFirstResponder];
        return;
    }
    
    // API CALL.
    [self api_SaveServiceRequest];
}

#pragma mark -  API call.

- (IBAction) api_GetServiceType
{
    NSLog(@"--> api_GetServiceType");
    
    //
//    [self showLoadingHUD:@"正在提交服务申请..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getServiceType";
    
    /*
    NSDictionary *account = [saveData objectForKey:@"Account"];
    NSString *serviceCode = [account  objectForKey:@"servicecode"];
    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/getServiceType", serviceCode];
    */
    
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token", nil];
    
    NSLog(@"--> api_GetServiceType --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetServiceType -> RESULT = %@", str);
        
        //
        [self getServiceType:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetServiceType -> ERROR = %@", [error description]);
        [self showMessageHUD:@"获取服务类型失败，请重试！"];
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) getServiceType:(id)theData
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
    NSLog(@"--> COUNT = %lu", (unsigned long)[records count]);
    if (records.count == 0) {
        [self showMessageHUD:@"没有查询到数据."];
        return;
    }
    
    //
//    self.myPickerData = [NSArray arrayWithArray:records];
    self.myPickerData = records;
    [self.myPickerView reloadAllComponents];
    [self showMessageHUD:@"服务类型已加载."];
    NSLog(@"IS NSArray -> self.myPickerData -> %@", self.myPickerData);
}

- (void) api_SaveServiceRequest
{
    NSLog(@"--> api_SaveServiceRequest");
    
    //
    [self showLoadingHUD:@"正在提交服务申请..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    NSString *token       = [saveData objectForKey:@"Token"];
    NSString *description = self.txtDescription.text;
    NSString *serviceType = self.labServiceType.text;
    NSString *details     = self.txtDetails.text;
    NSString *compId      = [saveData objectForKey:@"YSJ_ID"];
    NSString *contacter   = self.txtContacter.text;
    NSString *telephone   = self.txtTelephone.text;
    NSString *expectDate  = self.labExpectDate.text;
    
    //--------------------
    NSString *nextPath = @"cis/mobile/saveServiceRequest";
    
    /*
    NSDictionary *account = [saveData objectForKey:@"Account"];
    NSString *serviceCode = [account  objectForKey:@"servicecode"];
    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/saveServiceRequest", serviceCode];
    */
    
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,        @"token",
                               description,  @"description",
                               serviceType,  @"serviceType",
                               details,      @"details",
                               compId,       @"compId",
                               contacter,    @"contacter",
                               telephone,    @"telephone",
                               expectDate,   @"expectDate",
                               nil];
    
    NSLog(@"--> api_SaveServiceRequest --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_SaveServiceRequest -> RESULT = %@", str);
        
        // Check result.
        [self checkResult:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_SaveServiceRequest -> ERROR = %@", [error description]);
        [self showMessageHUD:@"提交服务申请失败，请重试！"];
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) checkResult:(id)theData
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
    NSLog(@"--> api_SaveServiceRequest --> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
        //        [self showMessageHUD:@"更新失败，请重试！"];
    } else {
        [self showMessageHUD:@"提交服务申请成功！"];
    }
}

#pragma mark - Keyboad Method.

- (void) hideKeyboard_RS {
    [self dataViewHidden];
    [self moveTableView:107];
    [self.txtDetails     resignFirstResponder];
    [self.txtTelephone   resignFirstResponder];
    [self.txtContacter   resignFirstResponder];
    [self.txtDescription resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 10) {  //
        [self.txtContacter becomeFirstResponder];
    } else if (textField.tag == 11) { //
        [self.txtTelephone becomeFirstResponder];
    } else if (textField.tag == 12) { //
        [self.txtDetails becomeFirstResponder];
    } else if (textField.tag == 14) { //
        [textField resignFirstResponder];
        [self hideKeyboard_RS];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 11:
        case 12:
        case 14:
            [self moveTableView:60];
            break;
            
        default:
            break;
    }
}

#pragma mark - MBProgressHUD methods

//
- (void) showMessageHUD:(NSString *)msg
{
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
