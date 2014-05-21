//
//  VSRootViewController.m
//  VictoryStep
//
//  Created by Steven on 5/12/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSRootViewController.h"
#import "VSSlidingViewController.h"


@interface VSRootViewController ()

@property (nonatomic, strong) VSSlidingViewController* slidingViewController;
@property (nonatomic, strong) UIViewController* slidingTopViewController;

@end

@implementation VSRootViewController

- (instancetype) init
{
    if (self = [super init])
    {
        self.slidingTopViewController = [[UIViewController alloc] init];
        self.slidingTopViewController.view.backgroundColor = [UIColor redColor];
        self.slidingViewController = [[VSSlidingViewController alloc] initWithTopViewController: self.slidingTopViewController];
        
        [self addChildViewController: self.slidingViewController];
        [self.view addSubview: self.slidingViewController.view];
    }
    
    return self;
}

- (void) loadView
{
    [super loadView];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear: (BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
