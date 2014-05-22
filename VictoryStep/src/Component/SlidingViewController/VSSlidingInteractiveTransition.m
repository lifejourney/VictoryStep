//
//  VSSlidingInteractiveTransition.m
//  VictoryStep
//
//  Created by Steven on 5/16/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSSlidingInteractiveTransition.h"
#import "VSSlidingViewController.h"


@interface VSSlidingInteractiveTransition ()

@property (nonatomic, assign) VSSlidingViewController* slidingViewController;

@property (nonatomic, assign) BOOL isFromLeftToRight;
@property (nonatomic, assign) CGFloat fullWidth;

@property (nonatomic, copy) void (^coordinatorInteractionEnded)(id<UIViewControllerTransitionCoordinatorContext> context);

@end

@implementation VSSlidingInteractiveTransition

- (instancetype) initWithSlidingViewController: (VSSlidingViewController*)slidingViewController
{
    if (self = [super init])
    {
        self.slidingViewController = slidingViewController;
    }
    
    return self;
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void) startInteractiveTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    [super startInteractiveTransition: transitionContext];
    
    UIViewController* topViewController = [transitionContext viewControllerForKey: kVSTransitionContextTopViewControllerKey];
    
    CGFloat initialLeftEdge = CGRectGetMidX([transitionContext initialFrameForViewController: topViewController]);
    CGFloat finalLeftLeftEdge = CGRectGetMidX([transitionContext finalFrameForViewController: topViewController]);
    
    self.isFromLeftToRight = initialLeftEdge < finalLeftLeftEdge;
    self.fullWidth = fabsf(finalLeftLeftEdge - initialLeftEdge);
}

#pragma mark - UIPanGestureRecognizer action

- (void) updateTopViewHorizontalCenterWithRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translationX = [recognizer translationInView: self.slidingViewController.view].x;
    CGFloat velocityX = [recognizer velocityInView: self.slidingViewController.view].x;
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            BOOL isPanningRight = (velocityX > 0);
            
            switch (self.slidingViewController.currentTopViewPosition)
            {
                case VSSlidingViewControllerTopViewPositionAnchoredLeft:
                case VSSlidingViewControllerTopViewPositionAnchoredRight:
                {
                    [self.slidingViewController resetTopViewAnimated: YES];
                    
                    break;
                }
                    
                case VSSlidingViewControllerTopViewPositionCentered:
                {
                    if (isPanningRight)
                        [self.slidingViewController anchorTopViewToRightAnimated: YES];
                    else
                        [self.slidingViewController anchorTopViewToLeftAnimated: YES];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            if (!self.isFromLeftToRight)
                translationX = translationX * -1.0;
            
            CGFloat percentComplete = (translationX < 0) ? 0 : (translationX / self.fullWidth);
            
            [self updateInteractiveTransition: percentComplete];
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            BOOL isPanningToRight = (velocityX > 0);
            
            if (self.coordinatorInteractionEnded)
                self.coordinatorInteractionEnded((id<UIViewControllerTransitionCoordinatorContext>)self.slidingViewController);
            
            if (isPanningToRight == self.isFromLeftToRight)
                [self finishInteractiveTransition];
            else
                [self cancelInteractiveTransition];
            
            break;
        }
            
        default:
            break;
    }
}

@end


