//
//  RunRecord.m -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-运行记录）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-12.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "RunRecord.h"

@interface RunRecord ()

@end

@implementation RunRecord


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
    
    self.myPickerData = [[NSArray alloc] initWithObjects:
                         @"1分钟", @"5分钟", @"10分钟", @"15分钟", @"30分钟", @"1小时", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"历史数据数据量很大，请尽量在免费WIFI下使用";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    switch (indexPath.row) {
        case 0:
            CellIdentifier = @"StartTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labStartTime  = (UILabel *)[cell viewWithTag:10];
            break;
        case 1:
            CellIdentifier = @"EndTime";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labEndTime    = (UILabel *)[cell viewWithTag:11];
            break;
        case 2:
            CellIdentifier = @"TimeJG";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            self.labTimeJG     = (UILabel *)[cell viewWithTag:12];
            break;
        default:
            break;
    }
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
//    self.labStartTime  = (UILabel *)[cell viewWithTag:10];
//    self.labEndTime    = (UILabel *)[cell viewWithTag:11];
//    self.labTimeJG     = (UILabel *)[cell viewWithTag:12];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    curLine = indexPath.row;
    
    if (curLine == 0 || curLine == 1) { // Start and End time select.
        self.myDataView.hidden   = NO;
        self.myPickerView.hidden = YES;
        self.myDatePicker.hidden = NO;
    } else {
        self.myDataView.hidden   = NO;
        self.myDatePicker.hidden = YES;
        self.myPickerView.hidden = NO;
    }
}

#pragma mark - Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.myPickerData count];
}

#pragma mark - Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row             forComponent:(NSInteger)component
{
    return [self.myPickerData objectAtIndex:row];
}


- (IBAction)selectValue
{
    NSLog(@"selectValue");
    
    self.myDataView.hidden   = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd  HH:mm"];
    
    if (curLine == 0) { // 开始时间
        NSString *startTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labStartTime.text = startTime;
    } else if (curLine == 1) { // 结束时间
        NSString *endTime  = [formatter stringFromDate:self.myDatePicker.date];
        self.labEndTime.text = endTime;
    } else if (curLine == 2) { // 时间间隔
        NSInteger selValue  = [self.myPickerView selectedRowInComponent:0];
        self.labTimeJG.text = [self.myPickerData objectAtIndex:selValue];
    }
}

@end
