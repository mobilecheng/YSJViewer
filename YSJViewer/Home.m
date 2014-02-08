//
//  ViewController.m -- 主菜单页面
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "Home.h"
#import "GlobalValue.h"

@interface Home ()

@property (nonatomic) NSMutableArray *arrYSJ_ID;   // 压缩机 ID
@property (nonatomic) NSMutableArray *arrModel;  // 压缩机型号
@property (nonatomic) NSMutableArray *arrName;   // 压缩机名字

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation Home

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //
    [self initData];
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    [self api_CompressorList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  Init Data.

- (void) initData
{
    self.arrName   = [[NSMutableArray alloc] init];
    self.arrModel  = [[NSMutableArray alloc] init];
    self.arrYSJ_ID = [[NSMutableArray alloc] init];
}

#pragma mark -  API call.

- (void) api_CompressorList
{
    NSLog(@"--> Home --> apiCompressorList");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getCompressorList";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token",
                               nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:dicParams
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> Home --> apiCompressorList -> RESULT = %@", str);
        
        [self getCompressorList:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> Home --> apiCompressorList -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) getCompressorList:(id)theData
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
        //            [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    NSArray *records = [dicData objectForKey:@"records"];
    NSLog(@"HOME--> IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
    
    // 构造参数，用于订阅信息查询
    NSMutableArray *tempIDInfo = [[NSMutableArray alloc] init];
    
    //
    for (NSDictionary *recordData in records) {
        NSLog(@"---------------------------------------");
        
        // 压缩机ID
        NSLog(@"DATA --> 压缩机-id   = %@", [recordData objectForKey:@"id"]);
        [self.arrYSJ_ID addObject:[recordData objectForKey:@"id"]];
        
        // 压缩机名称
        NSLog(@"DATA --> alias   = %@", [recordData objectForKey:@"alias"]);
        [self.arrName addObject:[recordData objectForKey:@"alias"]];
        
        // 压缩机型号
        NSLog(@"DATA --> model   = %@", [recordData objectForKey:@"model"]);
        [self.arrModel addObject:[recordData objectForKey:@"model"]];
        
        //-------
        /*
//        NSLog(@"DATA --> cSN     = %@", [recordData objectForKey:@"cSN"]);
//        [self.arrSN addObject:[recordData objectForKey:@"cSN"]];
        
        NSString *cId = [recordData objectForKey:@"cId"];
        NSLog(@"DATA --> cId     = %@", cId);
//        [self.arrCID addObject:cId];
        
        NSString *sID = [recordData objectForKey:@"sId"];
        NSLog(@"DATA --> sId     = %@", sID);
//        [self.arrSID addObject:sID];
        
        // 构造参数，用于订阅信息查询
        NSDictionary *idInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                sID, @"sId", cId, @"cId", nil];
        [tempIDInfo addObject:idInfo];
        */
        
        // Items
        /*
        NSLog(@"    ---> ------------------------------------");
        NSMutableArray *tempIID   = [[NSMutableArray alloc] init];
        NSMutableArray *tempName  = [[NSMutableArray alloc] init];
        NSMutableArray *tempUnit  = [[NSMutableArray alloc] init];
        
        NSArray *items = [recordData objectForKey:@"items"];  // Get All items.
        
        for (NSDictionary *itemData in items) {
            NSLog(@"    ITEMS --> iId   = %@", [itemData objectForKey:@"iId"]);
            [tempIID  addObject:[itemData objectForKey:@"iId"]];
            
            NSLog(@"    ITEMS --> name   = %@", [itemData objectForKey:@"name"]);
            [tempName addObject:[itemData objectForKey:@"name"]];
            
            NSLog(@"    ITEMS --> unit   = %@", [itemData objectForKey:@"unit"]);
            [tempUnit addObject:[itemData objectForKey:@"unit"]];
        }
        
        // Save items data.
        [self.arrItems_iID  addObject:tempIID];
        [self.arrItems_name addObject:tempName];
        [self.arrItems_unit addObject:tempUnit];
         */
    }
    
    /*
    // 构造参数，用于订阅信息查询
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            tempIDInfo, @"data", nil];
    NSString *dataForQuery = [params jsonEncodedKeyValueString];
//    NSLog(@"--> 参数用于订阅信息查询 = %@", dataForQuery);
    */
    
    // Save data to cache.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:self.arrYSJ_ID forKey:@"HOME_YSJ_ID"];
    [saveData setObject:self.arrName   forKey:@"HOME_YSJ_NAME"];
    [saveData setObject:self.arrModel  forKey:@"HOME_YSJ_MODEL"];
    [saveData synchronize];
}


@end
