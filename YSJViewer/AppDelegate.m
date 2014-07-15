//
//  AppDelegate.m -- 程序入口
//  YSJViewer
//
//  Created by Reload Digital Tech. on 14-1-2.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // for test noti
    //取消所有通知
//    [application cancelAllLocalNotifications];
    // 图标上的数字 = 0
    application.applicationIconBadgeNumber = 0;
    //获取本地推送数组
    NSArray *localArray = [application scheduledLocalNotifications];
    NSLog(@"scheduledLocalNotifications  = %@", localArray);
    
    // 6-20 update.
    // 服务器 IP 地址写死。 Save Server Address to cache.
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setObject:@"112.124.59.36" forKey:@"ServerAddress"];
    [saveData synchronize];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // test
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 4-16 Add
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:notification.alertBody delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
    // 图标上的数字减1
//    application.applicationIconBadgeNumber -= 1;
    
    //获取本地推送数组
//    NSArray *localArray1 = [application scheduledLocalNotifications];
//    NSLog(@"scheduledLocalNotifications 1 = %@", localArray1);
    
    //
    [application cancelLocalNotification:notification];
    
    //获取本地推送数组
//    NSArray *localArray2 = [application scheduledLocalNotifications];
//    NSLog(@"scheduledLocalNotifications 2 = %@", localArray2);
}
@end
