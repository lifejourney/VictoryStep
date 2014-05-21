//
//  VSSlidingInteractiveTransition.h
//  VictoryStep
//
//  Created by Steven on 5/16/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSPercentDrivenInteractiveTransition.h"


@class VSSlidingViewController;


@interface VSSlidingInteractiveTransition : VSPercentDrivenInteractiveTransition

- (instancetype) initWithSlidingViewController: (VSSlidingViewController*)slidingViewController;
- (void) updateTopViewHorizontalCenterWithRecognizer: (UIPanGestureRecognizer*)recognizer;

@end
