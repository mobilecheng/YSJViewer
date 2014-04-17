//
//  ViewController.h -- 主菜单页面
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface Home : UIViewController <SRWebSocketDelegate>

{
    SRWebSocket *srWebSocket;
}
@end
