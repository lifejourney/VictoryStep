//
//  VSRootViewController.m
//  VictoryStep
//
//  Created by Steven on 5/12/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSRootViewController.h"
#import "VSAppDelegate.h"

@interface VSRootViewController ()

@end

@implementation VSRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.title = @"Hello";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectMake(100, 100, 120, 20)];
    textLabel.text = @"Hello";
    
    [self.view addSubview: textLabel];
    
}

- (void) viewWillAppear: (BOOL)animated
{
    NSLog(@"viewWillAppear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
