//
//  ReserveHistoryDetail.m -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-预约服务）--> 详情
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-23.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "ReserveHistoryDetail.h"
#import "GlobalValue.h"

@interface ReserveHistoryDetail ()

@property (nonatomic) NSMutableArray *arrItemName;
@property (nonatomic) NSMutableArray *arrItemValue;

@property (nonatomic) UILabel *labName;
@property (nonatomic) UILabel *labValue;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation ReserveHistoryDetail

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
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_ShowServiceRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == 4) {
//        return 80;
//    }
//    
//    return 44;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    NSLog(@"self.arrItemName.count = %d", self.arrItemName.count);
    return self.arrItemName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ReserveHistoryDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labItemName = (UILabel *)[cell viewWithTag:10];
    labItemName.text = [self.arrItemName objectAtIndex:indexPath.row];
    
    //
    UILabel *labItemValue = (UILabel *)[cell viewWithTag:11];
    labItemValue.text = [self.arrItemValue objectAtIndex:indexPath.row];
    
    //
    return cell;
}

#pragma mark -  Init Data.

- (void)initData
{
    self.arrItemName  = [[NSMutableArray alloc] init];
    self.arrItemValue = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

// API -获取指定压缩机服务申请
- (void) api_ShowServiceRequest
{
    NSLog(@"--> api_ShowServiceRequest...");
    
    //
    [self showLoadingHUD:@"正在加载..."];
    
    // 构造参数
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token  = [saveData  objectForKey:@"Token"];
    NSString *iId    = [saveData  objectForKey:@"RESERVE_ID"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/showServiceRequest";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token", iId, @"id", nil];
    
    NSLog(@"--> api_ShowServiceRequest -> dicParams = %@", dicParams);
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_ShowServiceRequest -> RESULT = %@", str);
        
        [self showServiceRequest:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_ShowServiceRequest -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

- (void) showServiceRequest:(id)theData
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
    
    NSDictionary *record = [dicData objectForKey:@"record"];
    NSLog(@"--> COUNT = %d", [record count]);
    if (record.count == 0) {
        [self showMessageHUD:@"没有服务申请详情数据."];
        return;
    }
    
    //----
    /*
    if ([record isKindOfClass:[NSString class]]) {
        NSLog(@"--> NSString class");
    } else if ([record isKindOfClass:[NSDictionary class]]) {
        NSLog(@"--> NSDictionary class");
    } else if ([record isKindOfClass:[NSArray class]]) {
        NSLog(@"--> NSArray class");
    } else {
        NSLog(@"--> NO KNOW");
    }
     */
    //----
    
    NSLog(@"IS NSDictionary -> %@", record);
    
    //
//    NSLog(@"---------------------------------------");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *compName  = [saveData  objectForKey:@"YSJ_NAME"];
    
    [self.arrItemValue addObject:compName];
    [self.arrItemValue addObject:[record objectForKey:@"description"]];
    [self.arrItemValue addObject:[record objectForKey:@"state"]];
    [self.arrItemValue addObject:[record objectForKey:@"serviceType"]];
    [self.arrItemValue addObject:[record objectForKey:@"details"]];
    [self.arrItemValue addObject:[record objectForKey:@"contacter"]];
    [self.arrItemValue addObject:[record objectForKey:@"telephone"]];
    [self.arrItemValue addObject:[record objectForKey:@"expectDate"]];
//    [self.arrItemValue addObject:[record objectForKey:@"comments"]];
    
    NSLog(@"self.arrItemValue -> %@", self.arrItemValue);
    
    //
    self.arrItemName = [[NSMutableArray alloc] initWithObjects:
                        @"压缩机", @"描述", @"状态", @"服务类型",
                        @"详情", @"联系人", @"联系电话", @"期望时间", nil];

    NSLog(@"arrItemName -> %@", self.arrItemName);
    
    // 刷新数据
    [self.tableView reloadData];
    
//    [self performSelector:@selector(reloadTableView) withObject:nil afterDelay:0.01f];
}

#pragma mark -  IBAction Methods.

- (IBAction) refreshData
{
    NSLog(@"refreshReserveHistoryDetailData");
    
    [self.arrItemName   removeAllObjects];
    [self.arrItemValue  removeAllObjects];
    
    [self.tableView reloadData];
    [self api_ShowServiceRequest];
}

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void) reloadTableView
{
    // 刷新数据
    [self.tableView reloadData];
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
