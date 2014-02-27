//
//  RealTimeData_LineChart.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-23.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RealTimeData_LineChart.h"
#import "GlobalValue.h"

#define degreesToRadians(x) (M_PI * x / 180.0)

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
    
    // test
    [self showLineChart];
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

#pragma mark - 显示曲线

//- (NSUInteger) supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeRight;
//}
//
//- (BOOL) shouldAutorotate
//{
//    return NO;
//}


- (void) showLineChart
{
    /*
//    UIInterfaceOrientation orientation = [UIDevice currentDevice].orientation;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation) || orientation == UIDeviceOrientationUnknown)
    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)])
        {
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
                                           withObject:(NSUInteger)UIDeviceOrientationLandscapeRight];
        }
    }
    
    //
//    [[UIDevice currentDevice] performSelector:@selector(setOrientation:)
//                                   withObject:(id)UIDeviceOrientationLandscapeRight];
    */
    
    
    CGRect webFrame = self.view.frame;
    webFrame.origin.x = 0;
    webFrame.origin.y =  0;
    
    webViewForSelectDate = [[UIWebView alloc] initWithFrame:webFrame];
    webViewForSelectDate.delegate = self;
    webViewForSelectDate.scalesPageToFit = YES;
    webViewForSelectDate.opaque = NO;
    webViewForSelectDate.backgroundColor = [UIColor clearColor];
    webViewForSelectDate.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:webViewForSelectDate];
    
    //所有的资源都在source.bundle这个文件夹里
    NSString* htmlPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"source.bundle/index.html"];
    
    NSURL* url = [NSURL fileURLWithPath:htmlPath];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webViewForSelectDate loadRequest:request];
    int trueWidth = self.view.frame.size.width;
    if (trueWidth < self.view.frame.size.height && ![UIApplication sharedApplication].statusBarHidden)
    {
        trueWidth = self.view.frame.size.height + MIN([UIApplication sharedApplication].statusBarFrame.size.height,[UIApplication sharedApplication].statusBarFrame.size.width);
    }
    
    /*
    CGRect closeBtnFrame = CGRectMake(trueWidth - 70, 0, 70, 20);
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:closeBtnFrame];
    [closeBtn setTitle:@"close" forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.view addSubview:closeBtn];
    [self.view bringSubviewToFront:closeBtn];
    */
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
//    self.navigationController.navigationBar.transform = CGAffineTransformMakeRotation(M_PI/2);
    
//    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
//    self.view.bounds = CGRectMake(0, 0, 568, 320);
    
    
//    CGRect newBounds = CGRectMake(0, 0, 568, 320);
//    self.navigationController.view.bounds = newBounds;
//    self.navigationController.view.center = CGPointMake(newBounds.size.height / 2.0, newBounds.size.width / 2.0);
//    
//    self.navigationController.view.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
    
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    
    CGRect newBounds = CGRectMake(0, 0, 568, 320);
    self.navigationController.view.bounds = newBounds;
    self.navigationController.view.center = CGPointMake(newBounds.size.height / 2.0, newBounds.size.width / 2.0);
    
    self.navigationController.view.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    self.navigationController.view.transform = CGAffineTransformIdentity;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
    self.navigationController.view.bounds = CGRectMake(0.0, 0.0, 320.0, 568.0);
    
    [super viewWillDisappear:animated];
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
