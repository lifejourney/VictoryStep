//
//  UIViewController+VSSlidingViewController.m
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "UIViewController+VSSlidingViewController.h"


@implementation UIViewController (VSSlidingViewController)

- (VSSlidingViewController*) nearestAncestorSlidingViewController
{
    UIViewController *viewController = self;
    
    do
    {
        viewController = viewController.parentViewController ? viewController.parentViewController : viewController.presentingViewController;
    }
    while (viewController != nil && [viewController isKindOfClass: [VSSlidingViewController class]]);
    
    return (VSSlidingViewController*)viewController;
}

@end
