//
//  VSRootViewController.m
//  VictoryStep
//
//  Created by Steven on 5/12/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSRootViewController.h"
#import "VSSlidingViewController.h"
#import "VSMainMenuViewController.h"


@interface VSRootViewController ()

@property (nonatomic, strong) VSSlidingViewController* slidingViewController;
@property (nonatomic, strong) UINavigationController* navController;
@property (nonatomic, strong) UIViewController* mainMenuViewController;
@property (nonatomic, strong) UIViewController* contentViewController;

@end

@implementation VSRootViewController

- (instancetype) init
{
    if (self = [super init])
    {
        self.contentViewController = [[UIViewController alloc] init];
        self.contentViewController.view.backgroundColor = [UIColor orangeColor];
        self.contentViewController.title = @"Hello";
        UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithTitle: @"Menu" style: UIBarButtonItemStyleBordered target: self action: @selector(onMainMenuClick:)];
        self.contentViewController.navigationItem.leftBarButtonItem = leftItem;
        
        self.navController = [[UINavigationController alloc] initWithRootViewController: self.contentViewController];
        self.navController.navigationBar.backgroundColor = [UIColor greenColor];
        //[self.navController.navigationBar setHidden: YES];
        
        self.mainMenuViewController = [[UIViewController alloc] init];
        self.mainMenuViewController.view.backgroundColor = [UIColor redColor];
        
        self.slidingViewController = [[VSSlidingViewController alloc] init];
        self.slidingViewController.leftSlideViewController = self.mainMenuViewController;
        [self.navController.view addGestureRecognizer: self.slidingViewController.panGesture];
        self.slidingViewController.topViewController = self.navController;
        //self.slidingViewController.topViewAnchoredGestureMask = (VSSlidingViewControllerAnchoredGesturePanning | VSSlidingViewControllerAnchoredGestureTapping);
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
    
    [self addChildViewController: self.slidingViewController];
    [self.view addSubview: self.slidingViewController.view];
}

- (void) viewWillAppear: (BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - target action

- (void) onMainMenuClick: (NSObject*)sender
{
    [self.slidingViewController anchorTopViewToRightAnimated: YES];
}
@end
