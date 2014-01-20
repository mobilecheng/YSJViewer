//
//  RunRecord.h
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

@property (nonatomic) UILabel *labStartTime;
@property (nonatomic) UILabel *labEndTime;
@property (nonatomic) UILabel *labTimeJG;

@property (nonatomic) NSArray *myPickerData;


@end
