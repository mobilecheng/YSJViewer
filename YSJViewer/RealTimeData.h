//
//  RealTimeData.h -- 主菜单 --> 设备监控 --> 点压缩机列表名称 --> 点菜单项（三级页面-实时数据）
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface RealTimeData : UITableViewController <SRWebSocketDelegate>
{
    SRWebSocket *srWebSocket;
}
@end
