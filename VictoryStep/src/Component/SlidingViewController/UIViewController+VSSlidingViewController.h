//
//  UIViewController+VSSlidingViewController.h
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSSlidingViewController.h"


@interface UIViewController (VSSlidingViewController)

- (VSSlidingViewController*) nearestAncestorSlidingViewController;

@end
