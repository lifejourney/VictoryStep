//
//  VSPercentDrivenInteractiveTransition.h
//  VictoryStep
//
//  Created by Steven on 5/16/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VSPercentDrivenInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animatedController;
@property (nonatomic, readonly, assign) CGFloat percentComplete;

- (void) updateInteractiveTransition: (CGFloat)percentComplete;
- (void) cancelInteractiveTransition;
- (void) finishInteractiveTransition;

@end
