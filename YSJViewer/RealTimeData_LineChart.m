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

#define degreesToRadians(x) (M_PI * x / 180.0)


@interface RealTimeData_LineChart ()

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labXValue_1;
@property (weak, nonatomic) IBOutlet UILabel *labXValue_2;
@property (weak, nonatomic) IBOutlet UILabel *labXValue_3;
@property (weak, nonatomic) IBOutlet UILabel *labXValue_4;
@property (weak, nonatomic) IBOutlet UILabel *labXValue_5;
@property (weak, nonatomic) IBOutlet UIImageView *imgXValue_1;
@property (weak, nonatomic) IBOutlet UIImageView *imgXValue_2;
@property (weak, nonatomic) IBOutlet UIImageView *imgXValue_3;
@property (weak, nonatomic) IBOutlet UIImageView *imgXValue_4;
@property (weak, nonatomic) IBOutlet UIImageView *imgXValue_5;

@property (nonatomic) MKNetworkEngine *engine;

@property (nonatomic) NSUInteger dataCount;

@property (nonatomic) NSMutableArray *arrValue;
@property (nonatomic) NSMutableArray *arrDate;

@property (nonatomic) NSTimer *myTimer;

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
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:strHostName
                   customHeaderFields:nil];
    
    //
    [self initData];
    
    //
    [self api_GetRecentItemData];
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    
    CGRect newBounds = CGRectMake(0, 0, 568, 320);
    self.navigationController.view.bounds = newBounds;
    self.navigationController.view.center = CGPointMake(newBounds.size.height / 2.0, newBounds.size.width / 2.0);
    
    self.navigationController.view.transform = CGAffineTransformMakeRotation(degreesToRadians(90));
    
    // 每隔5秒更新一次数据
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:(5.0) target:self selector:@selector(api_GetRecentItemData) userInfo:nil repeats:YES];

    //
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    self.navigationController.view.transform = CGAffineTransformIdentity;
    self.navigationController.view.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
    self.navigationController.view.bounds = CGRectMake(0, 0, 320, 568);
    
    // 取消5秒更新
    [self.myTimer invalidate];
    self.myTimer = nil;
    
    //
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrValue  = [[NSMutableArray alloc] init];
    self.arrDate   = [[NSMutableArray alloc] init];
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
    NSString *iId    = [saveData  objectForKey:@"RL_iID"];
    NSString *name   = [saveData  objectForKey:@"RL_Name"];
    
    // 显示标题
    self.labTitle.text = name;
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getRecentItemData";
    
    /*
    NSDictionary *account = [saveData objectForKey:@"Account"];
    NSString *serviceCode = [account  objectForKey:@"servicecode"];
    NSString *nextPath = [NSString stringWithFormat:@"cisn/%@/mobile/getRecentItemData", serviceCode];
    */
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token", compId, @"compId", iId, @"iId", nil];
    
    NSLog(@"--> api_GetRecentItemData -> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetRecentItemData -> RESULT = %@", str);
        
        [self getRecentItemData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetRecentItemData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getRecentItemData:(id)theData
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
    NSLog(@"--> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    NSArray *records = [dicData objectForKey:@"records"];
    self.dataCount = records.count;
    NSLog(@"--> COUNT = %d", self.dataCount);
    if (self.dataCount == 0) {
        [self showMessageHUD:@"没有实时数据."];
        return;
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", self.dataCount, [records objectAtIndex:0]);
    
    // 清空之前数据
    [self.arrDate  removeAllObjects];
    [self.arrValue removeAllObjects];
    
    //
    for (NSDictionary *recordData in records) {
//        NSLog(@"---------------------------------------");
        
//        NSLog(@"DATA --> value    = %@", [recordData objectForKey:@"value"]);
        [self.arrValue addObject:[recordData objectForKey:@"value"]];
        
        //
//        NSLog(@"DATA --> date     = %@", [recordData objectForKey:@"date"]);
        [self.arrDate addObject:[recordData objectForKey:@"date"]];
    }
    
    // 绘制曲线
    [self showLineChart];
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
    //
    LCLineChartData *d1 = [LCLineChartData new];
    
    // 定义数据
    d1.xMin = 1;
    d1.xMax = self.dataCount;
//    d1.title = @"Foobarbang";
    d1.color = [UIColor blackColor];
    d1.itemCount = self.dataCount;
    
    //给曲线图加数据
    NSMutableArray *vals = [NSMutableArray new];
    for (int i = 0; i < d1.itemCount; i++) {
        [vals addObject:[NSString stringWithFormat:@"%d", i + 1]];
    }
    
    d1.getData = ^(NSUInteger item) {
        float x = [vals[item] floatValue];
        float y = [self.arrValue[item] floatValue];
        
        NSString *x_label = self.arrDate[item];
        x_label = [x_label substringFromIndex:11];
        NSString *y_label = [NSString stringWithFormat:@"%.2f", y];
        
        return [LCLineChartDataItem dataItemWithX:x y:y xLabel:x_label dataLabel:y_label];
    };
    
    
    
    // 显示曲线图 Add to view.
    LCLineChartView *chartView = [[LCLineChartView alloc] initWithFrame:CGRectMake(0, 80, 550, 230)];
//    chartView.backgroundColor= [UIColor blueColor];
    
    // for test
    NSMutableArray *arrY = [NSMutableArray arrayWithArray:self.arrValue];
    [arrY sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
//    for (int i = 0; i < arrY.count; i++) {
//        NSLog(@"rese = %@", arrY[i]);
//    }
    
    // Y轴数值显示
    float iMin = [arrY[0] floatValue];
    float iMax = [arrY[arrY.count - 1] floatValue];
    iMin -= iMin * 0.1;
    iMax += iMax * 0.1;
//    NSLog(@"iMin = %f", iMin);
//    NSLog(@"iMax = %f", iMax);
    
    //
    float stepValue = (iMax - iMin) / 9.0;
    NSMutableArray *arrSteps = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        float nextValue = iMin + stepValue * i;
        NSString *strValue = [NSString stringWithFormat:@"%.2f", nextValue];
        [arrSteps addObject:strValue];
    }
    
    //
    chartView.yMin = iMin;
    chartView.yMax = iMax;
    
    NSString *strMax = [NSString stringWithFormat:@"%.6f", iMax];
    NSLog(@"strMax = %@", strMax);
    if ([strMax isEqualToString:@"0.000000"] ) {
        chartView.ySteps = @[@"0.00", @""];
    } else {
        chartView.ySteps = arrSteps;
    }
    
    chartView.data = @[d1];
    [self.view addSubview:chartView];
    
    // X轴5个时间点显示
    NSLog(@"RTD-self.arrDate.count = %d", self.arrDate.count);
    
    // 5-4 update.
    int timeCount = self.arrDate.count;
    int one   = 2;
    int two   = timeCount * 0.26;
    int three = timeCount * 0.52;
    int four  = timeCount * 0.78;
    int five  = timeCount - 2;
    NSLog(@"TEST = %d | %d | %d", two, three, four);
    
    NSString *x_time = [self.arrDate[one] substringFromIndex:11];
    self.labXValue_1.text = x_time;
    [self.view addSubview:self.labXValue_1];
    
    x_time = [self.arrDate[two] substringFromIndex:11];
    self.labXValue_2.text = x_time;
    [self.view addSubview:self.labXValue_2];
    
    x_time = [self.arrDate[three] substringFromIndex:11];
    self.labXValue_3.text = x_time;
    [self.view addSubview:self.labXValue_3];
    
    x_time = [self.arrDate[four] substringFromIndex:11];
    self.labXValue_4.text = x_time;
    [self.view addSubview:self.labXValue_4];
    
    x_time = [self.arrDate[five] substringFromIndex:11];
    self.labXValue_5.text = x_time;
    [self.view addSubview:self.labXValue_5];
    
    [self.view addSubview:self.imgXValue_1];
    [self.view addSubview:self.imgXValue_2];
    [self.view addSubview:self.imgXValue_3];
    [self.view addSubview:self.imgXValue_4];
    [self.view addSubview:self.imgXValue_5];
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
