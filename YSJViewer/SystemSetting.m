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

//@property (weak, nonatomic) IBOutlet UIButton *btnCheckAppUpdate;
@property (weak, nonatomic) IBOutlet UISwitch *switchVibration;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation SystemSetting

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

    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) btnCheckAppUpdate
{
    NSLog(@"btnCheckAppUpdate");
    
    [self api_CheckNewVersion];
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
