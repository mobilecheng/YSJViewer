//
//  UserInfo.m
//  YSJViewer
//
//  Created by Kevin Zhang on 14-1-15.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "UserInfo.h"
#import "GlobalValue.h"

@interface UserInfo ()

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation UserInfo

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //
    self.engine = [[MKNetworkEngine alloc]
                   initWithHostName:hostName
                   customHeaderFields:nil];
    
    //
    self.labUserName.text = @"张诚";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/* 因为在使用Static Cell，所以不需要data source
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Name";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark -  API call.

- (void) api_MyInfo
{
    NSLog(@"--> api_MyInfo");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getMyInfo";
    
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
        NSLog(@"--> apiCompressorList -> RESULT = %@", str);
        
//        [self getMyInfoList:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> apiCompressorList -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}

/*
- (void) getMyInfoList:(id)theData
{
    NSError *error = nil;
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:theData
                                                            options:NSJSONReadingAllowFragments error:&error];
    if (!error) {
        
        // Check result.
        NSString *strResult = [dicData objectForKey:@"result"];
        NSLog(@"--> strResult = %@", strResult);
        if ([strResult isEqualToString:@"error"]) {
            [self showMessageHUD:[dicData objectForKey:@"message"]];
            return;
        }
        
        NSArray *records = [dicData objectForKey:@"records"];
        NSLog(@"IS NSArray -> Count is : %d  | 1 Data is: %@", [records count], [records objectAtIndex:0]);
        
        for (NSDictionary *recordData in records) {
            NSLog(@"---------------------------------------");
            
            NSLog(@"DATA --> alias   = %@", [recordData objectForKey:@"alias"]);
            [self.arrName addObject:[recordData objectForKey:@"alias"]];
            
            NSLog(@"DATA --> cSN     = %@", [recordData objectForKey:@"cSN"]);
            [self.arrSN addObject:[recordData objectForKey:@"cSN"]];
            
            NSLog(@"DATA --> model   = %@", [recordData objectForKey:@"model"]);
            [self.arrModel addObject:[recordData objectForKey:@"model"]];
            
            NSLog(@"DATA --> cId     = %@", [recordData objectForKey:@"cId"]);
            [self.arrCID addObject:[recordData objectForKey:@"cId"]];
            
            NSLog(@"DATA --> sId     = %@", [recordData objectForKey:@"sId"]);
            [self.arrSID addObject:[recordData objectForKey:@"sId"]];
            
            
            // Items
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
        }
        
        // 刷新数据
        [self.tableView reloadData];
        
    } else {
        NSLog(@"--> ERROR = %@", error.description);
    }
}
*/

#pragma mark - MBProgressHUD methods

// 显示收藏信息
- (void)showMessageHUD:(NSString *)msg {
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

@end
