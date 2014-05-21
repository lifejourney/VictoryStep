//
//  VSSlidingViewController.h
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSSlidingViewControllerDefine.h"


@class VSSlidingViewController;


@protocol VSSlidingViewControllerLayout <NSObject>

- (CGRect) slidingViewController: (VSSlidingViewController*)slidingViewController
          frameForViewController: (UIViewController*)viewController
                 topViewPosition: (VSSlidingViewControllerTopViewPosition)topViewPoistion;

@end

@protocol VSSlidingViewControllerDelegate

@optional

- (id<UIViewControllerAnimatedTransitioning>) slidingViewController: (VSSlidingViewController*)slidingViewController
                                    animationControllerForOperation: (VSSlidingViewControllerOperation)operation
                                                  topViewController: (UIViewController*)topViewController;

- (id<UIViewControllerInteractiveTransitioning>) slidingViewController: (VSSlidingViewController*)slidingViewController
                           interactionControllerForAnimationController: (id<UIViewControllerAnimatedTransitioning>)animationController;

- (id<VSSlidingViewControllerLayout>) slidingViewController: (VSSlidingViewController*)slidingViewController
                         layoutControllerForTopViewPosition: (VSSlidingViewControllerTopViewPosition)topViewPosition;


@end

@interface VSSlidingViewController : UIViewController < UIViewControllerContextTransitioning,
                                                        UIViewControllerTransitionCoordinator,
                                                        UIViewControllerTransitionCoordinatorContext>


@property (nonatomic, strong) UIViewController* topViewController;
@property (nonatomic, strong) UIViewController* underViewController;

@property (nonatomic, strong) NSString* topViewControllerStoryoardID;
@property (nonatomic, strong) NSString* underViewControllerStoryoardID;

@property (nonatomic, assign) CGFloat fixedTopViewLengthIfAnchored;
@property (nonatomic, assign) CGFloat fixedTopViewLengthIfCentered;

@property (nonatomic, assign) id<VSSlidingViewControllerDelegate> delegate;

@property (nonatomic, assign) VSSlidingViewControllerAnchorPosition anchorPosition;
@property (nonatomic, assign) VSSlidingViewControllerTopViewPosition currentTopViewPosition;

@property (nonatomic, assign) VSSlidingViewControllerAnchoredGesture topViewAnchoredGestureMask;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong, readonly) UITapGestureRecognizer* resettingTapGesture;
@property (nonatomic, strong) NSArray* customAnchoredGestureArray;

@property (nonatomic, assign) NSTimeInterval defaultTransitionDuration;

+ (instancetype) slidingViewControllerWithTopViewController: (UIViewController*)topViewController;
- (instancetype) initWithTopViewController: (UIViewController*)topViewController;

- (void) anchorTopViewToLeftAnimated: (BOOL)animated;
- (void) anchorTopViewToLeftAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;
- (void) anchorTopViewToRightAnimated: (BOOL)animated;
- (void) anchorTopViewToRightAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;
- (void) resetTopViewAnimated: (BOOL)animated;
- (void) resetTopViewAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;

@end


