//
//  RealTimeData.h
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
