//
//  YSJ_List_TVC.m
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-5.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "YSJ_List_TVC.h"

#define hostName @"117.34.92.46:80"

@interface YSJ_List_TVC ()

@property (nonatomic) NSMutableArray *arrName;   // 压缩机名字
@property (nonatomic) NSMutableArray *arrSN;     // 压缩机编号
@property (nonatomic) NSMutableArray *arrModel;  // 压缩机型号
@property (nonatomic) NSMutableArray *arrStatus; // 压缩机状态（在线、离线）

//@property (nonatomic) NSString *strToken; // 

@property (nonatomic) MKNetworkEngine *engine;

@end

@implementation YSJ_List_TVC

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
    [self initData];
    
    //
    [self setExtraCellLineHidden:self.tableView];
    
    //
    [self api_CompressorList];
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
    NSLog(@"压缩机数量 = %d", [self.arrName count]);
    return [self.arrName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"YSJ_List_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Cell Image Icon
//    UIImageView *cellIcon = (UIImageView *)[cell viewWithTag:100];
//    cellIcon.image = [self imageForRating:player.rating];
    
    // 压缩机名字
    UILabel *labName = (UILabel *)[cell viewWithTag:101];
    labName.text = [self.arrName objectAtIndex:indexPath.row];
    
    // 压缩机编号
    UILabel *labSN = (UILabel *)[cell viewWithTag:102];
    labSN.text = [self.arrSN objectAtIndex:indexPath.row];
    
    // 压缩机型号
    UILabel *labModel = (UILabel *)[cell viewWithTag:103];
    labModel.text = [self.arrModel objectAtIndex:indexPath.row];
    
    // 压缩机状态
    UILabel *labStatus = (UILabel *)[cell viewWithTag:104];
    labStatus.text = @"在线";
    
    //
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [self.arrName objectAtIndex:indexPath.row];
    NSLog(@"YSJ name = %@", name);
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    [saveData setObject:name forKey:@"YSJ_NAME"];
    [saveData synchronize];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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

#pragma mark -  Uitility Methods.

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


#pragma mark -  Init Data.

- (void)initData
{
    self.arrName   = [[NSMutableArray alloc] init];
    self.arrSN     = [[NSMutableArray alloc] init];
    self.arrModel  = [[NSMutableArray alloc] init];
    self.arrStatus = [[NSMutableArray alloc] init];
}


#pragma mark -  API call.

- (void) api_CompressorList
{
    NSLog(@"--> apiCompressorList");
    
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    NSString *token = [saveData  objectForKey:@"Token"];
    
    //--------------------
//    NSString *hostName = @"117.34.92.46:80";
    NSString *nextPath = @"cis/mobile/getCompressorList";
    
    // params
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                               token, @"token",
                               nil];
    
//    MKNetworkEngine* engine = [[MKNetworkEngine alloc]
//                               initWithHostName:hostName
//                               customHeaderFields:nil];
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                params:dicParams
                                            httpMethod:@"GET"
                                                   ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> apiCompressorList -> RESULT = %@", str);
        
        [self getCompressorList:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> apiCompressorList -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) getCompressorList:(id)theData
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
            
        }
        
        // 刷新数据
        [self.tableView reloadData];
        
    } else {
        NSLog(@"--> ERROR = %@", error.description);
    }
}


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
