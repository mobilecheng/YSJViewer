//
//  ServiceTime.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-服务时间）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-16.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "ServiceTime.h"
#import "GlobalValue.h"

@interface ServiceTime ()

@property (weak, nonatomic) IBOutlet UILabel *labCompName;
@property (weak, nonatomic) IBOutlet UITableView *tvData;

@property (nonatomic) UIImageView *imgProgress;

@property (nonatomic) NSMutableArray *arrItem;
@property (nonatomic) NSMutableArray *arrValue;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation ServiceTime

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
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.labCompName.text = [saveData stringForKey:@"YSJ_NAME"];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tvData];
    
    //
    [self api_GetServiceTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"INIT CELL COUNT");
    return [self.arrItem count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"INIT CELL SERVICE");
    
    static NSString *CellIdentifier = @"ServiceTime";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labItems = (UILabel *)[cell viewWithTag:10];
    labItems.text = [self.arrItem objectAtIndex:indexPath.row];
    
    // Progress.
    self.imgProgress = (UIImageView *)[cell viewWithTag:11];
    
    CGRect testFrame = self.imgProgress.frame;
    float value = [[self.arrValue objectAtIndex:indexPath.row] floatValue];
    
    if ( value >= 0.00f && value <= 0.40f ) {
        self.imgProgress.image = [UIImage imageNamed:@"progress_green_bg"];
        testFrame.size.width = testFrame.size.width * value;
        testFrame.size.width = 10;
        NSLog(@"testFrame.size.width  = %f", testFrame.size.width);
        self.imgProgress.frame = testFrame;
    }
    
    //
    return cell;
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrItem = [[NSMutableArray alloc] init];
    self.arrValue    = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

- (void) api_GetServiceTime
{
    NSLog(@"--> api_GetServiceTime...");
    
    //
    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token  = [saveData objectForKey:@"Token"];
    NSString *compId = [saveData objectForKey:@"YSJ_ID"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getServiceTime";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,    @"token",
                               compId,   @"compId",
                               nil];
    
    NSLog(@"--> api_GetServiceTime --> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetServiceTime -> RESULT = %@", str);
        
        [self getServiceTimeData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetServiceTime -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) getServiceTimeData:(id)theData
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
    NSLog(@"--> COUNT = %d", [records count]);
    if (records.count == 0) {
        [self showMessageHUD:@"没有服务时间数据."];
        return;
    }
    
    NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    // 解析数据
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        //
        NSString *item = [recordData objectForKey:@"item"];
        NSLog(@"DATA --> item     = %@", item);
        [self.arrItem addObject:item];
        
        //
        NSString *maxValue = [recordData objectForKey:@"maxValue"];
        NSLog(@"DATA --> maxValue    = %@", maxValue);
        NSString *value = [recordData objectForKey:@"value"];
        NSLog(@"DATA --> value    = %@", value);
        
        float result = [value floatValue] / [maxValue floatValue];
        NSString *strResult = [NSString stringWithFormat:@"%.2f", result];
        NSLog(@"DATA --> strResult    = %@", strResult);
        [self.arrValue addObject:strResult];
    }
    
    // 刷新数据
    [self.tvData reloadData];
}

#pragma mark -  Uitility Methods.

- (IBAction)go:(id)sender {
    
    // 刷新数据
    [self.tvData reloadData];
    
    
    //test
//    CGRect testFrame = self.imgProgress.frame;
//    testFrame.size.width = 60;
//    self.imgProgress.frame = testFrame;
}


- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
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
