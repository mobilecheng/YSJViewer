//
//  AlarmInfoDetail.m -- 主菜单 --> 报警信息 --> 报警信息详情
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-9.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "AlarmInfoDetail.h"
#import "GlobalValue.h"

@interface AlarmInfoDetail ()

@property (weak, nonatomic) IBOutlet UILabel *labCompName;
@property (weak, nonatomic) IBOutlet UILabel *labAlarmTime;
@property (weak, nonatomic) IBOutlet UILabel *labAlarmInfo;
@property (weak, nonatomic) IBOutlet UITableView *tabDetail;

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation AlarmInfoDetail

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
    [self setExtraCellLineHidden:self.tabDetail];
    
    //
    [self api_GetAlarmDetail];
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
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AlarmInfoDetail";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    UILabel *labItems_name = (UILabel *)[cell viewWithTag:10];
//    labItems_name.text = [self.arrItems_name objectAtIndex:indexPath.row];
    
    UILabel *labItems_value = (UILabel *)[cell viewWithTag:11];
//    labItems_value.text = [self.arrItems_value objectAtIndex:indexPath.row];
    
    //
    return cell;
}

#pragma mark -  API call.

- (void) api_GetAlarmDetail
{
    NSLog(@"--> api_GetAlarmDetail...");
    
    //
//    [self showLoadingHUD:@"正在查询..."];
    
    //
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    
    // 构造参数
    NSString *token   = [saveData  objectForKey:@"Token"];
    NSString *alarmID = @"21";
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getAlarmDetail";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token,   @"token",
                               alarmID, @"id",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetAlarmDetail -> RESULT = %@", str);
        
//        [self getAlarmData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetAlarmData -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
@end
