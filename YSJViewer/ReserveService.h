//
//  ReserveService.h -- 主菜单 --> 设备监控 --> 压缩机列表 --> 菜单项（三级页面-预约服务）
//  YSJViewer
//
//  Created by Kevin Zhang on 14-2-21.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReserveService : UIViewController <UITableViewDelegate,
    UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource,
    UITextFieldDelegate, UIAlertViewDelegate>

{
    NSInteger curLine;
}

@end
