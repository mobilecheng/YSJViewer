//
//  HistoryData.h -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-历史数据）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-11.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryData : UIViewController <UITableViewDelegate, UITableViewDataSource,
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
@property (nonatomic) UILabel *labJCL;

@property (nonatomic) NSArray *myPickerData;
@property (nonatomic) NSArray *myJCLData;
@property (nonatomic) NSString *myJCLData_SelValue;

@property (nonatomic) MKNetworkEngine *engine;


@end
