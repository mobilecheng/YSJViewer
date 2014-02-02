//
//  UserInfoUpdate.m
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

    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    self.txtUserName.delegate       = self;
    self.txtOfficePhone.delegate     = self;
    self.txtMobilePhone.delegate = self;
    
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


#pragma mark - Keyboad Method.

//键盘出现时候调用的事件
-(void) keyboadWillShow:(NSNotification *)note{
    
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
}

//键盘消失时候调用的事件
-(void)keyboardWillHide:(NSNotification *)note{
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect testFrame = self.view.frame;
                         testFrame.origin.y = 0;
                         self.view.frame = testFrame;
                     }
                     completion:^(BOOL finished) {
                         //
                     }];
}

- (void) hideKeyboard {
    [self.txtID       resignFirstResponder];
    [self.txtName     resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {  // User ID.
        [self.txtName becomeFirstResponder];
    } else if (textField.tag == 1) { // User Name.
        [self.txtPassword becomeFirstResponder];
    } else if (textField.tag == 2) { // Password.
        [textField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark -  API call.

- (void) api_UpdateMyInfo
{
    NSLog(@"--> api_UpdateMyInfo");
    
    //
//    [self showLoadingHUD];
    
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
        NSLog(@"--> userLogin -> RESULT = %@", str);
        
        [self getToken:data saveInfo:dicParams];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> userLogin -> ERROR = %@", [error description]);
        [self showMessageHUD:@"登录失败，请检查网络设置！"];
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


@end
