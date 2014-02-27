//
//  NavLogin.m
//  YSJViewer
//
//  Created by TMC_MAC_02 on 14-2-27.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "NavLogin.h"

@interface NavLogin ()

@end

@implementation NavLogin

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger) supportedInterfaceOrientations
{
    NSLog(@"nav-1");
    return UIInterfaceOrientationMaskPortrait;
//    return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL) shouldAutorotate
{
    NSLog(@"nav-2");
    return NO;
//    return self.topViewController.shouldAutorotate;
}

@end
