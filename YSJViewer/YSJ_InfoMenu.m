//
//  YSJ_InfoMenu.m -- 主菜单 --> 设备监控 --> 点压缩机列表名称（二级页面-压缩机信息菜单）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-5.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "YSJ_InfoMenu.h"

@interface YSJ_InfoMenu ()


@end

@implementation YSJ_InfoMenu

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

    // Title.
    NSUserDefaults *saveData  = [NSUserDefaults standardUserDefaults];
    self.navigationItem.title = [saveData stringForKey:@"YSJ_NAME"];
    
    // 菜单名字
//    self.arrMenu = [NSArray arrayWithObjects:
//                    @"实时数据", @"运行记录", @"服务时间", @"历史数据",
//                    @"预约服务", @"预约历史", @"历史报警", nil];
    
    [self setExtraCellLineHidden:self.tableView];
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
//    NSLog(@"self.arrMenu = %d", [self.arrMenu count]);
//    return [self.arrMenu count];
    
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"Menu_0";
            break;
        case 1:
            CellIdentifier = @"Menu_1";
            break;
        case 2:
            CellIdentifier = @"Menu_2";
            break;
        case 3:
            CellIdentifier = @"Menu_3";
            break;
        case 4:
            CellIdentifier = @"Menu_4";
            break;
        case 5:
            CellIdentifier = @"Menu_5";
            break;
        case 6:
            CellIdentifier = @"Menu_6";
            break;
        default:
            break;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
    // Configure the cell...
    
    // Cell Image Icon
//    UIImageView *cellIcon = (UIImageView *)[cell viewWithTag:100];
//    cellIcon.image = [self imageForRating:player.rating];
    
    // 压缩机信息菜单列表
//    UILabel *labMenu = (UILabel *)[cell viewWithTag:101];
//    labMenu.text = [self.arrMenu objectAtIndex:indexPath.row];
 
    //
    return cell;
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

- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
@end
