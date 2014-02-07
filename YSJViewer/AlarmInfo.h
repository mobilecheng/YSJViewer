//
//  AlarmInfo.h -- 主菜单 --> 报警信息
//  YSJViewer
//
//  Created by Kevin Zhang on 14-1-31.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface AlarmInfo : UITableViewController <SRWebSocketDelegate>
{
    SRWebSocket *srWebSocket;
}
@end
