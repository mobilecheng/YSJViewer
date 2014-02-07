//
//  UserInfoUpdate.m -- 主菜单 --> 用户信息 --> 修改信息
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "UserInfoUpdate.h"
#import "GlobalValue.h"

@interface UserInfoUpdate ()

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation UserInfoUpdate

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

    // Background image - Single Tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:singleTap];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    self.txtUserName.delegate       = self;
    self.txtOfficePhone.delegate     = self;
    self.txtMobilePhone.delegate = self;
    self.txtFax.delegate     = self;
    self.txtEmail.delegate = self;
    
    //注册键盘出现与隐藏时候的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //
    [self getCurrentUserInfo];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 用户现有信息
- (void) getCurrentUserInfo
{
    NSDictionary *recordData = [[NSUserDefaults standardUserDefaults] objectForKey:@"USER_INFO"];
    
    NSLog(@"DATA --> name   = %@", [recordData objectForKey:@"name"]);
    self.txtUserName.text = [recordData objectForKey:@"name"];
    
    NSLog(@"DATA --> officePhone     = %@", [recordData objectForKey:@"officePhone"]);
    self.txtOfficePhone.text = [recordData objectForKey:@"officePhone"];
    
    NSLog(@"DATA --> mobilePhone   = %@", [recordData objectForKey:@"mobilePhone"]);
    self.txtMobilePhone.text = [recordData objectForKey:@"mobilePhone"];
    
    NSLog(@"DATA --> fax     = %@", [recordData objectForKey:@"fax"]);
    self.txtFax.text = [recordData objectForKey:@"fax"];
    
    NSLog(@"DATA --> email     = %@", [recordData objectForKey:@"email"]);
    self.txtEmail.text = [recordData objectForKey:@"email"];
}


#pragma mark - Commit Button Methods.

- (IBAction)buttonClick
{
    NSLog(@"buttonClick");
    
    // Check the text that NO NULL.
    NSString *strUserName = [self.txtUserName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strUserName isEqualToString:@""]) { // No Ueser Name
        [self showMessageHUD:@"用户名不能为空."];
        return;
    }
    
    NSString *strOfficePhone = [self.txtOfficePhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strOfficePhone isEqualToString:@""]) { //
        [self showMessageHUD:@"办公电话不能为空."];
        return;
    }
    
    NSString *strMobilePhone = [self.txtMobilePhone.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strMobilePhone isEqualToString:@""]) { //
        [self showMessageHUD:@"手机号码不能为空."];
        return;
    }
    
    NSString *strEmail = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strEmail isEqualToString:@""]) { //
        [self showMessageHUD:@"邮箱不能为空."];
        return;
    }
    
    //
    [self api_UpdateMyInfo];
}

#pragma mark - Keyboad Method.

//键盘出现时候调用的事件
-(void) keyboadWillShow:(NSNotification *)note{
    /*
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.view.frame;
                         if ( bIPhone5 ) {
                             testFrame.origin.y = -80;
                         } else {
                             testFrame.origin.y = -140;
                         }
                         self.view.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                         
                     }];
     */
}

//键盘消失时候调用的事件
-(void)keyboardWillHide:(NSNotification *)note{
    /*
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.view.frame;
                         testFrame.origin.y = 0;
                         self.view.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
     */
}

- (void) hideKeyboard {
    [self.txtUserName       resignFirstResponder];
    [self.txtOfficePhone     resignFirstResponder];
    [self.txtMobilePhone resignFirstResponder];
    [self.txtFax resignFirstResponder];
    [self.txtEmail resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {  // User Name.
        [self.txtOfficePhone becomeFirstResponder];
    } else if (textField.tag == 1) { //
        [self.txtMobilePhone becomeFirstResponder];
    } else if (textField.tag == 2) { //
        [self.txtFax becomeFirstResponder];
    } else if (textField.tag == 3) { //
        [self.txtEmail becomeFirstResponder];
    } else if (textField.tag == 4) { //
        [textField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark -  API call.

- (void) api_UpdateMyInfo
{
    NSLog(@"--> api_UpdateMyInfo");
 
    // Remove noti.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //
    [self showLoadingHUD];
    
    //
    NSString *token       = [[NSUserDefaults standardUserDefaults] objectForKey:@"Token"];
    NSString *userName    = self.txtUserName.text;
    NSString *officePhone = self.txtOfficePhone.text;
    NSString *mobilePhone = self.txtMobilePhone.text;
    NSString *fax         = self.txtFax.text;
    NSString *email       = self.txtEmail.text;
    
    //--------------------
    NSString *nextPath = @"cis/mobile/updateMyInfo";
    
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,         @"token",
                               userName,      @"name",
                               officePhone,   @"officePhone",
                               mobilePhone,   @"mobilePhone",
                               fax,           @"fax",
                               email,         @"email",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> 更新用户信息 -> RESULT = %@", str);
        
        // Check result.
        [self checkResult:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> 更新用户信息 -> ERROR = %@", [error description]);
        [self showMessageHUD:@"更新用户信息失败，请检查网络设置！"];
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
    NSLog(@"--> UserInfoUpdate --> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
    } else {
        [self showMessageHUD:@"更新用户信息成功！"];
    }
}

#pragma mark - MBProgressHUD methods

// 显示收藏信息
- (void)showMessageHUD:(NSString *)msg {
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}


- (void)showLoadingHUD{
	
	MBProgressHUD *loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	loadingHUD.mode = MBProgressHUDModeIndeterminate;
	loadingHUD.labelText = @"更新用户信息中...";
	loadingHUD.removeFromSuperViewOnHide = YES;
    [loadingHUD hide:YES afterDelay:2];
}

@end
