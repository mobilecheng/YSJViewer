//
//  SystemSetting.m -- 主菜单 --> 系统设置
//  YSJViewer
//
//  Created by Kevin Zhang on 14-3-25.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "SystemSetting.h"
#import "GlobalValue.h"

@interface SystemSetting ()

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISwitch *switchVibration;

@property (nonatomic) MKNetworkEngine *engine;

//---------
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (weak, nonatomic) IBOutlet UIView *myDataView;

@property (nonatomic) NSArray *myPickerData;
@property (nonatomic) NSArray *arrCompID;
@property (nonatomic) NSString *selectCompID;
//---------


@end

@implementation SystemSetting

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    self.myPickerData = [[NSArray alloc] initWithObjects:
                         @"1", @"2", @"3", @"7", @"15", nil];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
        case 1:
            return 1;
        case 2:
            return 2;
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"SS_1";
            break;
        case 1:
            CellIdentifier = @"SS_2";
            break;
        case 2:
            CellIdentifier = @"SS_3";
            break;
        case 3:
            CellIdentifier = @"SS_4";
            break;
        default:
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    //
    return cell;
    
    
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

- (IBAction) btnCheckAppUpdate
{
    NSLog(@"btnCheckAppUpdate");
    
    [self api_CheckNewVersion];
}

- (IBAction) selectValue
{
    NSLog(@"selectValue");
    
    [self HiddenDataView];
    
    NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
    NSString *str = [NSString stringWithFormat:@"压缩机：%@", [self.myPickerData objectAtIndex:selValue]];
    
    
}

- (IBAction) ShowDataView
{
    // myDataView 的位置是 Y = 350 （为了做动画，初始 Y = 570）
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.myDataView.frame;
                         testFrame.origin.y = 425;
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

#pragma mark -  API call.

- (void) api_CheckNewVersion
{
    NSLog(@"--> api_CheckNewVersion");
    
    [self showLoadingHUD:@"正在查询..."];
    
//    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
//    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/checkNewVersion";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"compAide", @"appType",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_CheckNewVersion -> RESULT = %@", str);
        
        [self parseData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_CheckNewVersion -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) parseData:(id)theData
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
    NSLog(@"--> checkNewVersion --> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        
        NSString *message = [dicData objectForKey:@"message"];
//        [self showMessageHUD:[dicData objectForKey:@"message"]];
        
        // 提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    //
    NSString *version = [dicData objectForKey:@"version"];
    NSString *info = [dicData objectForKey:@"info"];
    
    // 提示
    NSString *strMessage = [NSString stringWithFormat:@"有新版本：%@ - %@", version, info];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:strMessage
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - MBProgressHUD methods

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
