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
    [self api_GetAlarmDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString *alarmID = @"4345";
    
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

@end
