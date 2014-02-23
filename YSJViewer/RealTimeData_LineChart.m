//
//  RealTimeData_LineChart.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-23.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RealTimeData_LineChart.h"
#import "GlobalValue.h"

@interface RealTimeData_LineChart ()

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation RealTimeData_LineChart

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
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    [self api_GetRecentItemData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  API call.

// API - 曲线数据初始化
- (void) api_GetRecentItemData
{
    NSLog(@"--> api_GetRecentItemData...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *compId = [saveData  objectForKey:@"YSJ_ID"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getRecentItemData";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token", compId, @"compId", @"31", @"iId", nil];
    
    NSLog(@"--> api_GetRecentItemData -> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetRecentItemData -> RESULT = %@", str);
        
//        [self getCurrentData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetRecentItemData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
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
