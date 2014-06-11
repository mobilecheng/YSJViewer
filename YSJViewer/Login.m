//
//  Login.m -- 登录画面
//  YSJViewer
//
//  Created by TMC_MAC_02 on 14-1-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "Login.h"
#import "GlobalValue.h"

@interface Login ()

@property (nonatomic) IBOutlet UIImageView *imgBG;
@property (nonatomic) IBOutlet UITextField *txtID;
@property (nonatomic) IBOutlet UITextField *txtName;
@property (nonatomic) IBOutlet UITextField *txtPassword;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation Login

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
    bIPhone5 = NO;
    CGSize checkSize = [[UIScreen mainScreen] currentMode].size;
    screenHeight = checkSize.height;
    if ( (int)screenHeight == 1136 ) {
        bIPhone5 = YES;
    }
    
    NSLog(@"checkSize: %@  | Height = %f", NSStringFromCGSize(checkSize), screenHeight);
    
    // Background image - Single Tap
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    self.imgBG.userInteractionEnabled = YES;
    [self.imgBG addGestureRecognizer:singleTap];
    
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    //
    self.txtID.delegate       = self;
    self.txtName.delegate     = self;
    self.txtPassword.delegate = self;
    
    //
    if ([self checkLoginInfo]) { // Has login info.
        // 5-5 update.
        NSInteger userTag = [saveData integerForKey:@"SwitchUser"];
        if (userTag == 678) {
            [saveData removeObjectForKey:@"SwitchUser"];
        } else {
            [self api_SignIn];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //注册键盘出现与隐藏时候的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Login Button Methods.

- (IBAction)loginClick:(id)sender
{
    NSLog(@"loginClick");
   
    // Check the text that NO NULL.
    NSString *strID = [self.txtID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strID isEqualToString:@""]) { // No ID
        [self showMessageHUD:@"客户编号不能为空."];
        return;
    }
    
    NSString *strName = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strName isEqualToString:@""]) { // No User Name
        [self showMessageHUD:@"用户名不能为空."];
        return;
    }
    
    NSString *password = [self.txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([password isEqualToString:@""]) { // No password.
        [self showMessageHUD:@"密码不能为空."];
        return;
    }
    
    //
    [self api_SignIn];
}

- (void) goHomeScreen
{
    // Remove noti.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    // Go to Home screen.
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *homeVC     = [mainStoryboard instantiateViewControllerWithIdentifier:@"Home"];
    
    [self.navigationController pushViewController:homeVC animated:YES];
}


- (BOOL) checkLoginInfo
{
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSDictionary *account    = [saveData objectForKey:@"Account"];
    NSLog(@"--> checkLoginInfo -> Account = %@", account);
    
    if (account != nil) {
        if ([account count] != 0) {
            // Get account.
            self.txtID.text       = [account objectForKey:@"servicecode"];
            self.txtName.text     = [account objectForKey:@"username"];
            self.txtPassword.text = [account objectForKey:@"password"];
            
            return YES;
            
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
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

- (void) api_SignIn
{
    NSLog(@"--> api_SignIn");
    
    //
    [self showLoadingHUD:@"登录中..."];
    
    //
    NSString *serviceCode = self.txtID.text;
    NSString *userName    = self.txtName.text;
    NSString *password    = self.txtPassword.text;
    
    //--------------------
    NSString *nextPath = @"cis/mobile/signIn";
//    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/signIn", serviceCode];
    
    // params  @"013468000533137", @"imei",@"100007" longmen2 longmen
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               serviceCode, @"servicecode",
                               userName,    @"username",
                               password,    @"password",
                               
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


- (void) getToken:(id)theData saveInfo:(NSDictionary *)dicParams
{
    NSError *error = nil;
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:theData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        
        // Check result.
        NSString *strResult = [dicData objectForKey:@"result"];
        NSLog(@"--> strResult = %@", strResult);
        if ([strResult isEqualToString:@"error"]) {
            [self showMessageHUD:[dicData objectForKey:@"message"]];
            return;
        }
        
        //
        NSString *strToken = [dicData objectForKey:@"token"];
        NSLog(@"--> token = %@", strToken);
        
        NSString *CompanyName = [dicData objectForKey:@"CompanyName"];
        NSLog(@"--> CompanyName = %@", CompanyName);
        
        NSString *CompanyTel = [dicData objectForKey:@"CompanyTel"];
        NSLog(@"--> CompanyTel = %@", CompanyTel);
        
        NSString *CompanyEmail = [dicData objectForKey:@"CompanyEmail"];
        NSLog(@"--> CompanyEmail = %@", CompanyEmail);
        
        /*
         NSString *CompanyPage;
         if ([dicData objectForKey:@"CompanyPage"] == NULL) {
         CompanyPage = @"";
         } else {
         CompanyPage = [dicData objectForKey:@"CompanyPage"];
         }
         NSLog(@"--> CompanyPage = %@", CompanyPage);
         
         NSString *CompanyAddress = [dicData objectForKey:@"CompanyAddress"];
         if (CompanyAddress == nil) CompanyAddress = @"";
         NSLog(@"--> CompanyAddress = %@", CompanyAddress);
         */
        
        // Save account info.
        NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
        [saveData setObject:dicParams      forKey:@"Account"];
        [saveData setObject:strToken       forKey:@"Token"];
        [saveData setObject:CompanyName    forKey:@"CompanyName"];
        [saveData setObject:CompanyTel     forKey:@"CompanyTel"];
        [saveData setObject:CompanyEmail   forKey:@"CompanyEmail"];
        //        [saveData setObject:CompanyPage    forKey:@"CompanyPage"];
        //        [saveData setObject:CompanyAddress forKey:@"CompanyAddress"];
        [saveData synchronize];
        
        //
        [self goHomeScreen];
        
    } else {
        NSLog(@"--> getToken -> ERROR = %@", error.description);
        [self showMessageHUD:@"无法获得访问 Token."];
    }
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
