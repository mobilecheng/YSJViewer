//
//  Login.m
//  YSJViewer
//
//  Created by TMC_MAC_02 on 14-1-7.
//  Copyright (c) 2014年 Reload Digital Tech. All rights reserved.
//

#import "Login.h"
#import "TestNC.h"

@interface Login ()

@end

@implementation Login

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

- (IBAction)loginClick:(id)sender
{
    NSLog(@"loginClick");
    
    TestNC *nc = [[TestNC alloc] init];
    [self presentViewController:nc animated:YES completion:^{
        
    }];
}

@end