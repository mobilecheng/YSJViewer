//
//  RunRecord.h -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-运行记录）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-12.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RunRecord : UIViewController <UITableViewDelegate, UITableViewDataSource,
    UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSInteger curLine;
    
}

@property (weak, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (weak, nonatomic) IBOutlet UIView *myDataView;
@property (weak, nonatomic) IBOutlet UIButton *setCurrentTime;

@property (nonatomic) UILabel *labStartTime;
@property (nonatomic) UILabel *labEndTime;
@property (nonatomic) UILabel *labTimeJG;

@property (nonatomic) NSArray *myPickerData;
@property (nonatomic) NSArray *myTimeJGData;
@property (nonatomic) NSString *myTimeJGData_SelValue;

@property (nonatomic) MKNetworkEngine *engine;

@end
