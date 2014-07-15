//
//  InputServerAddress.m -- 输入服务器IP地址
//  YSJViewer
//
//  Created by Kevin Zhang on 14-4-20.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "InputServerAddress.h"
#import "GlobalValue.h"

@interface InputServerAddress ()

@property (nonatomic) IBOutlet UITextField *txtServerAddress;
@property (nonatomic) IBOutlet UIImageView *imgBG;

@end

@implementation InputServerAddress

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
    
    //--------------
    // 6-20 update.
    // 服务器 IP 地址写死。 Save Server Address to cache.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setObject:@"112.124.59.36" forKey:@"ServerAddress"];
    [saveData synchronize];
    
    
    // Background image - Single Tap
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
//    [self.imgBG addGestureRecognizer:singleTap];
    
    //
//    self.txtServerAddress.delegate = self;
    
    //
    if ([self checkServerAddressInfo]) { // Has Server Address info.
        [self goLoginScreen];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Confirm Button Methods.

- (IBAction) confirmClick:(id)sender
{
    NSLog(@"confirmClick");
    
    // Check the text that NO NULL.
    NSString *strServerAddress = [self.txtServerAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strServerAddress isEqualToString:@""]) { // No strServerAddress
        [self showMessageHUD:@"服务器域名或IP地址不能为空."];
        return;
    }
    
    // Save Server Address to cache.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setObject:strServerAddress forKey:@"ServerAddress"];
    [saveData synchronize];
    
    //
    [self goLoginScreen];
}

- (void) goLoginScreen
{
    // Go to Login screen.
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"LoginStoryboard" bundle:nil];
    UIViewController *loginVC     = [loginStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    
    [self.navigationController pushViewController:loginVC animated:NO];
//    [self.navigationController presentViewController:loginVC
//                                            animated:NO
//                                          completion:^{ }];
}

- (BOOL) checkServerAddressInfo
{
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strServerAddress = [saveData stringForKey:@"ServerAddress"];
    NSLog(@"--> checkServerAddressInfo -> strServerAddress = %@", strServerAddress);
    
    if (strServerAddress != nil) {
        // Get account.
        self.txtServerAddress.text = strServerAddress;
        
        return YES;
        
    } else {
        return NO;
    }
}

#pragma mark - Keyboad Method.

- (void) hideKeyboard {
    [self.txtServerAddress resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
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

@end
