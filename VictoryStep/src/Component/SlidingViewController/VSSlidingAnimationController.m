//
//  VSSlidingAnimationController.m
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSSlidingAnimationController.h"
#import "VSSlidingViewControllerDefine.h"


#define kVSSlidingAnimation_DefaultTransitionDuration (0.25)


@interface VSSlidingAnimationController ()

@property (nonatomic, copy) void (^coordinatorAnimations)(id<UIViewControllerTransitionCoordinatorContext>context);
@property (nonatomic, copy) void (^coordinatorCompletion)(id<UIViewControllerTransitionCoordinatorContext>context);
@end


@implementation VSSlidingAnimationController

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval) transitionDuration: (id<UIViewControllerContextTransitioning>)transitionContext
{
    return _defaultTransitionDuration ? _defaultTransitionDuration : kVSSlidingAnimation_DefaultTransitionDuration;
}

- (void) animateTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* topViewController = [transitionContext viewControllerForKey: kVSTransitionContextTopViewControllerKey];
    UIViewController* toViewController = [transitionContext viewControllerForKey: UITransitionContextToViewControllerKey];
    UIView* containerView = [transitionContext containerView];
    CGRect topViewInitialFrame = [transitionContext initialFrameForViewController: topViewController];
    CGRect topViewFinalFrame = [transitionContext finalFrameForViewController: topViewController];
    
    topViewController.view.frame = topViewInitialFrame;
    
    if (topViewController != toViewController)
    {
        toViewController.view.frame = [transitionContext finalFrameForViewController: toViewController];
        
        [containerView insertSubview: toViewController.view belowSubview: topViewController.view];
    }
    
    [UIView animateWithDuration: [self transitionDuration: transitionContext]
                     animations: ^{
                         [UIView setAnimationCurve: UIViewAnimationCurveLinear];
                         
                         if (self.coordinatorAnimations)
                         {
                             self.coordinatorAnimations((id<UIViewControllerTransitionCoordinatorContext>)transitionContext);
                         }
                         
                         topViewController.view.frame = topViewFinalFrame;
                     }
                     completion: ^(BOOL finished){
                         if ([transitionContext transitionWasCancelled])
                         {
                             topViewController.view.frame = topViewInitialFrame;
                         }
                         
                         if (self.coordinatorCompletion)
                         {
                             self.coordinatorCompletion((id<UIViewControllerTransitionCoordinatorContext>)transitionContext);
                         }
                         
                         [transitionContext completeTransition: finished];
                     }];
}
@end
