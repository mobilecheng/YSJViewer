//
//  About.m -- 主菜单 --> 系统设置 --> 关于
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-10.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "About.h"
#import "GlobalValue.h"

@interface About ()

@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;

@property (nonatomic) MKNetworkEngine *engine;

@property (nonatomic) NSString *strTel;
@property (nonatomic) NSString *strEmail;
@property (nonatomic) NSString *strURL;
@property (nonatomic) NSString *strAddress;

@end

@implementation About

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
//    [self api_GetCompanyInfo];
//    [self api_FetchLogo];
    
    // 5-4 add.
    self.labName.text = [saveData stringForKey:@"CompanyName"];
    self.strTel     = [saveData stringForKey:@"CompanyTel"];
    self.strEmail   = [saveData stringForKey:@"CompanyEmail"];
    self.strURL     = [saveData stringForKey:@"CompanyPage"];
    self.strAddress = [saveData stringForKey:@"CompanyAddress"];
    
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
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"Line_0";
            break;
        case 1:
            CellIdentifier = @"Line_1";
            break;
        case 2:
            CellIdentifier = @"Line_2";
            break;
        case 3:
            CellIdentifier = @"Line_3";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //
    UILabel *labTel = (UILabel *)[cell viewWithTag:10];
    labTel.text = self.strTel;
    
    UILabel *labEmail = (UILabel *)[cell viewWithTag:11];
    labEmail.text = self.strEmail;
    
    UILabel *labURL = (UILabel *)[cell viewWithTag:12];
    labURL.text = self.strURL;
    
    UILabel *labAddress = (UILabel *)[cell viewWithTag:13];
    labAddress.text = self.strAddress;
    
    //
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3) {
        return 59;
    }
    
    return 44;
}

#pragma mark -  API call.

- (void) api_FetchLogo
{
    NSLog(@"--> api_FetchLogo");
    
    //    [self showLoadingHUD:@"正在查询..."];
    
    // Get Server Address.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    NSString *strHostName = [NSString stringWithFormat:@"%@:80", [saveData stringForKey:@"ServerAddress"]];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/fetchLogo";
    NSString *url = [NSString stringWithFormat:@"http://%@/%@", strHostName, nextPath];
    NSLog(@"URL = %@", url);
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *img = [UIImage imageWithData:data];
    self.imgLogo.image = img;
    
//    UIImageView *test = [[UIImageView alloc] initWithFrame:CGRectMake(30, 350, 160, 160)];
//    test.image = img;
//    [self.view addSubview:test];
}

- (void) api_GetCompanyInfo
{
    NSLog(@"--> api_GetCompanyInfo");
    
//    [self showLoadingHUD:@"正在查询..."];
    
    //--------------------
    NSString *nextPath = @"cis/mobile/getCompanyInfo";
    
    MKNetworkOperation* op = [self.engine operationWithPath:nextPath
                                                     params:nil
                                                 httpMethod:@"GET"
                                                        ssl:NO];
    
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        NSData *data  = [completedOperation responseData];
        NSString *str = [completedOperation responseString];
        NSLog(@"--> api_GetCompanyInfo -> RESULT = %@", str);
        
        [self parseData:data];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        NSLog(@"--> api_GetCompanyInfo -> ERROR = %@", [error description]);
    }];
    
    // Exe...
    [self.engine enqueueOperation:op];
}


- (void) parseData:(id)theData
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
    NSLog(@"--> api_GetCompanyInfo --> strResult = %@", strResult);
    if ([strResult isEqualToString:@"error"]) {
        [self showMessageHUD:[dicData objectForKey:@"message"]];
        return;
    }
    
    //
    NSDictionary *record = [dicData objectForKey:@"record"];
    NSLog(@"--> COUNT = %d", [record count]);
    if (record.count == 0) {
        [self showMessageHUD:@"没有数据."];
        return;
    }
    
    //
    self.labName.text = [record objectForKey:@"name"];
    NSLog(@"DATA --> name   = %@", self.labName.text);
    
    self.strTel = [record objectForKey:@"tel"];
    NSLog(@"DATA --> tel   = %@", self.strTel);
    
    self.strEmail = [record objectForKey:@"email"];
    NSLog(@"DATA --> email   = %@", self.strEmail);
    
    self.strURL = [record objectForKey:@"url"];
    NSLog(@"DATA --> url   = %@", self.strURL);
    
    self.strAddress = [record objectForKey:@"address"];
    NSLog(@"DATA --> address   = %@", self.strAddress);
    
    // 刷新数据
    [self.myTableView reloadData];
}

#pragma mark -  Uitility Methods.

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
