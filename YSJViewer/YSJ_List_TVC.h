//
//  YSJ_List_TVC.h
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-5.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface YSJ_List_TVC : UITableViewController <SRWebSocketDelegate>

{
    SRWebSocket *srWebSocket;
}
@end
