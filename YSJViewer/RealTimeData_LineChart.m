//
//  RealTimeData_LineChart.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-23.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RealTimeData_LineChart.h"
#import "GlobalValue.h"
#import "LCLineChartView.h"
#import "ViewLineChart.h"


#define degreesToRadians(x) (M_PI * x / 180.0)
#define SECS_PER_DAY (86400)

@interface RealTimeData_LineChart ()

@property (nonatomic) MKNetworkEngine *engine;

@property (strong) NSDateFormatter *formatter;

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
    self.navigationController.view.bounds = CGRectMake(0, 0, 320, 568);
    
    [super viewWillDisappear:animated];
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
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyyMMMd" options:0 locale:[NSLocale currentLocale]]];
    
    LCLineChartData *d1 = [LCLineChartData new];
    
    // el-cheapo next/prev day. Don't use this in your Real Code (use NSDateComponents or objc-utils instead)
    NSDate *date1 = [[NSDate date] dateByAddingTimeInterval:((-3) * SECS_PER_DAY)];
    NSDate *date2 = [[NSDate date] dateByAddingTimeInterval:((2) * SECS_PER_DAY)];
    
    // 定义X轴数据
    d1.xMin = [date1 timeIntervalSinceReferenceDate];
    d1.xMax = [date2 timeIntervalSinceReferenceDate];
    d1.title = @"Foobarbang";
    d1.color = [UIColor blackColor];
    d1.itemCount = 6;
    
    //给曲线图加数据
    NSMutableArray *arr = [NSMutableArray array];
    for(NSUInteger i = 0; i < 4; ++i) {
        [arr addObject:@(d1.xMin + (rand() / (float)RAND_MAX) * (d1.xMax - d1.xMin))];
    }
    [arr addObject:@(d1.xMin)];
    [arr addObject:@(d1.xMax)];
    [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *arr2 = [NSMutableArray array];
    for(NSUInteger i = 0; i < 6; ++i) {
        [arr2 addObject:@((rand() / (float)RAND_MAX) * 6)];
    }
    
    d1.getData = ^(NSUInteger item) {
        float x = [arr[item] floatValue];
        float y = [arr2[item] floatValue];
        NSString *label1 = [self.formatter stringFromDate:[date1 dateByAddingTimeInterval:x]];
        NSString *label2 = [NSString stringWithFormat:@"%f", y];
        
        return [LCLineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
    };

    
    // 显示曲线图 Add to view.
    LCLineChartView *chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(0, 80, 550, 230)];
    chartView.yMin = 0;
    chartView.yMax = 6;
    chartView.ySteps = @[@"1.0",@"2.0",@"3.0",@"4.0",@"5.0",@"6.0"];
    chartView.data = @[d1];
    
    [self.view addSubview:chartView];
    
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
