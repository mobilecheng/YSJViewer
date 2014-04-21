//
//  Home_ReserveService.m -- 主菜单 --> 预约服务
//  YSJViewer
//
//  Created by TMC_MAC_02 on 14-3-17.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "Home_ReserveService.h"
#import "GlobalValue.h"

@interface Home_ReserveService ()

@property (weak, nonatomic) IBOutlet UITableView *tvData;
@property (weak, nonatomic) IBOutlet UIButton *butSelectComp;

@property (nonatomic) NSMutableArray *arrID;
@property (nonatomic) NSMutableArray *arrDescription;
@property (nonatomic) NSMutableArray *arrState;
@property (nonatomic) NSMutableArray *arrExpectDate;

//---------
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (weak, nonatomic) IBOutlet UIView *myDataView;

@property (nonatomic) NSMutableArray *myPickerData;
@property (nonatomic) NSArray *arrCompID;
@property (nonatomic) NSString *selectCompID;
//---------

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation Home_ReserveService

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
    
    //
    [self initData];
    
    // 压缩机ID
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.arrCompID = [saveData objectForKey:@"HOME_YSJ_ID"];
    
    // 滚轮数据
    NSArray *tempArr = [saveData objectForKey:@"HOME_YSJ_CSN"];
    [self.myPickerData addObject:@"全部"];
    for (int i = 0; i < tempArr.count; i++) {
        [self.myPickerData addObject:tempArr[i]];
    }
    
    // Get Server Address.
//    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    //
    [self setExtraCellLineHidden:self.tvData];
    
    //
    [self api_GetServiceRequest];
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
    return self.arrDescription.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReserveHistory_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labDescription = (UILabel *)[cell viewWithTag:10];
    labDescription.text = [self.arrDescription objectAtIndex:indexPath.row];
    
    UILabel *labExpectDate = (UILabel *)[cell viewWithTag:11];
    labExpectDate.text = [self.arrExpectDate objectAtIndex:indexPath.row];
    
    UILabel *labState = (UILabel *)[cell viewWithTag:12];
    labState.text = [self.arrState objectAtIndex:indexPath.row];
    
    //
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *iID  = [self.arrID objectAtIndex:indexPath.row];
    NSLog(@"HOME_iID = %@", iID);
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:iID  forKey:@"RESERVE_ID"];
    [saveData synchronize];
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrID          = [[NSMutableArray alloc] init];
    self.arrDescription = [[NSMutableArray alloc] init];
    self.arrState       = [[NSMutableArray alloc] init];
    self.arrExpectDate  = [[NSMutableArray alloc] init];
    
    self.myPickerData   = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

// API -获取服务申请列表（所有压缩机）
- (void) api_GetServiceRequest
{
    NSLog(@"--> HOME_api_GetServiceRequest...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *compId = self.selectCompID;
    NSString *max    = @"100";
    NSString *offset = @"0";
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getServiceRequest";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,  @"token",
                               max,    @"max",
                               offset, @"offset",
                               compId, @"compId",
                               nil];
    
    NSLog(@"--> HOME_api_GetServiceRequest -> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> HOME_api_GetServiceRequest -> RESULT = %@", str);
        
        [self getServiceRequest:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> HOME_api_GetServiceRequest -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getServiceRequest:(id)theData
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
    
    NSLog(@"IS NSArray -> Count is : %lu  | 1 Data is: %@", (unsigned long)[records count], [records objectAtIndex:0]);
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        //
        NSLog(@"DATA --> id     = %@", [recordData objectForKey:@"id"]);
        [self.arrID addObject:[recordData objectForKey:@"id"]];
        
        //
        NSLog(@"DATA --> description     = %@", [recordData objectForKey:@"description"]);
        [self.arrDescription addObject:[recordData objectForKey:@"description"]];
        
        //
        NSLog(@"DATA --> state     = %@", [recordData objectForKey:@"state"]);
        [self.arrState addObject:[recordData objectForKey:@"state"]];
        
        //
        NSLog(@"DATA --> expectDate     = %@", [recordData objectForKey:@"expectDate"]);
        [self.arrExpectDate addObject:[recordData objectForKey:@"expectDate"]];
    }
    
    // 刷新数据
    [self.tvData reloadData];
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
    
    [self HiddenDataView];
    
    NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
    NSString *str = [NSString stringWithFormat:@"压缩机：%@", [self.myPickerData objectAtIndex:selValue]];
    [self.butSelectComp setTitle:str forState:UIControlStateNormal];
    
    // get comp name, csn, id.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    if (selValue == 0) { // 全部
        self.selectCompID = @"";
        [saveData removeObjectForKey:@"YSJ_NAME"];
        [saveData removeObjectForKey:@"YSJ_CSN"];
        [saveData removeObjectForKey:@"YSJ_ID"];
        
    } else {
        self.selectCompID = [self.arrCompID objectAtIndex:selValue - 1];
        
        //
        NSArray *tempName = [saveData objectForKey:@"HOME_YSJ_NAME"];
        NSArray *tempCSN  = [saveData objectForKey:@"HOME_YSJ_CSN"];
        NSArray *tempID   = [saveData objectForKey:@"HOME_YSJ_ID"];
        
        for (int i = 0; i < tempID.count; i++) {
            NSString *strID = tempID[i];
            if ( [self.selectCompID intValue] == [strID intValue] ) {
                [saveData setObject:tempName[i] forKey:@"YSJ_NAME"];
                [saveData setObject:tempCSN[i]  forKey:@"YSJ_CSN"];
                [saveData setObject:tempID[i]   forKey:@"YSJ_ID"];
                [saveData synchronize];
                break;
            }
        }
    }
    
    //
    [self.arrDescription removeAllObjects];
    [self.arrExpectDate  removeAllObjects];
    [self.arrID          removeAllObjects];
    [self.arrState       removeAllObjects];
    
    // 刷新数据
    [self.tvData reloadData];
    
    //
    [self api_GetServiceRequest];
}

- (IBAction) ShowDataView
{
    // myDataView 的位置是 Y = 350 （为了做动画，初始 Y = 570）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myDataView.frame;
                         testFrame.origin.y = 350;
                         self.myDataView.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (IBAction) HiddenDataView
{
    // myDataView 的位置是 Y = 350 （为了做动画，初始 Y = 570）
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
