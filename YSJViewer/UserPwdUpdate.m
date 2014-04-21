//
//  UserPwdUpdate.m -- 主菜单 --> 用户信息 --> 修改密码
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "UserPwdUpdate.h"
#import "GlobalValue.h"

@interface UserPwdUpdate ()

@end

@implementation UserPwdUpdate

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
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    //
    self.txtCurrentPwd.delegate    = self;
    self.txtNewPwd.delegate        = self;
    self.txtConfirmNewPwd.delegate = self;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Commit Button Methods.

- (IBAction)buttonClick
{
    NSLog(@"buttonClick");
    
    // Check the text that NO NULL.
    NSString *strCurrentPwd = [self.txtCurrentPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strCurrentPwd isEqualToString:@""]) { // No Ueser Name
        [self showMessageHUD:@"密码不能为空."];
        [self.txtCurrentPwd becomeFirstResponder];
        return;
    } else {
        if (strCurrentPwd.length > 20 || strCurrentPwd.length < 6) {
            [self showMessageHUD:@"密码长度应该在6～20个字符."];
            [self.txtCurrentPwd becomeFirstResponder];
            return;
        }
    }
    
    NSString *strNewPwd = [self.txtNewPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strNewPwd isEqualToString:@""]) { //
        [self showMessageHUD:@"密码不能为空."];
        [self.txtNewPwd becomeFirstResponder];
        return;
    } else {
        if (strNewPwd.length > 20 || strNewPwd.length < 6) {
            [self showMessageHUD:@"密码长度应该在6～20个字符."];
            [self.txtNewPwd becomeFirstResponder];
            return;
        } else {
            if ([self.txtNewPwd.text isEqualToString:self.txtCurrentPwd.text]) {
                [self showMessageHUD:@"新密码不能和旧密码相同."];
                [self.txtNewPwd becomeFirstResponder];
                return;
            }
        }
    }
    
    NSString *strConfirmNewPwd = [self.txtConfirmNewPwd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([strConfirmNewPwd isEqualToString:@""]) { //
        [self showMessageHUD:@"密码不能为空."];
        [self.txtConfirmNewPwd becomeFirstResponder];
        return;
    } else {
        if (strConfirmNewPwd.length > 20 || strConfirmNewPwd.length < 6) {
            [self showMessageHUD:@"密码长度应该在6～20个字符."];
            [self.txtConfirmNewPwd becomeFirstResponder];
            return;
        } else {
            if ( ![self.txtConfirmNewPwd.text isEqualToString:self.txtNewPwd.text] ) {
                [self showMessageHUD:@"请确认新密码一致."];
                [self.txtConfirmNewPwd becomeFirstResponder];
                return;
            }
        }
    }
    
    
    // 提示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"确定要修改吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

//根据被点击按钮的索引处理点击事件
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickButtonAtIndex: %d", buttonIndex);
    
    if (buttonIndex == 0) { // 取消
        // Nothing.
    } else if (buttonIndex == 1) { // 确定
        [self api_ChangePwd];
    }
}

#pragma mark - Keyboad Method.

- (void) hideKeyboard {
    [self.txtCurrentPwd    resignFirstResponder];
    [self.txtNewPwd        resignFirstResponder];
    [self.txtConfirmNewPwd resignFirstResponder];
}

//点击return按钮所做的动作：
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {  // Current Pwd.
        [self.txtNewPwd becomeFirstResponder];
    } else if (textField.tag == 1) { //
        [self.txtConfirmNewPwd becomeFirstResponder];
    } else if (textField.tag == 2) { //
        [textField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark -  API call.

- (void) api_ChangePwd
{
    NSLog(@"--> api_ChangePwd");
    
    //
    [self showLoadingHUD:@"正在更新..."];
    
    //
    NSString *token  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Token"];
    NSString *oldPwd = self.txtCurrentPwd.text;
    NSString *newPwd = self.txtNewPwd.text;

    //--------------------
    NSString *nextPath = @"cis/mobile/changePwd";
    
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,    @"token",
                               oldPwd,   @"oldPwd",
                               newPwd,   @"newPwd",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> 更新用户密码 -> RESULT = %@", str);
        
        // Check result.
        [self checkResult:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> 更新用户密码 -> ERROR = %@", [error description]);
        [self showMessageHUD:@"更新失败，请重试！"];
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
    NSLog(@"--> UserPwdUpdate --> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
//        [self showMessageHUD:@"更新失败，请重试！"];
    } else {
        [self showMessageHUD:@"更新成功！"];
        [self performSelector:@selector(backPreviousScreen)
                   withObject:nil
                   afterDelay:delay];
        
    }
}

- (void) backPreviousScreen
{
    [self.navigationController popViewControllerAnimated:YES];
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
