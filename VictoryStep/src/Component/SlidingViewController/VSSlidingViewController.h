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
@property (nonatomic, strong) UIViewController* leftSlideViewController;
@property (nonatomic, strong) UIViewController* rightSlideViewController;

@property (nonatomic, strong) NSString* topViewControllerStoryoardID;
@property (nonatomic, strong) NSString* leftSlideViewControllerStoryoardID;
@property (nonatomic, strong) NSString* rightSlideViewControllerStoryoardID;

@property (nonatomic, assign) CGFloat fixedLeftSlideViewLengthIfAnchored;
@property (nonatomic, assign) CGFloat fixedLeftSlideViewLengthIfCentered;
@property (nonatomic, assign) CGFloat fixedRightSlideViewLengthIfAnchored;
@property (nonatomic, assign) CGFloat fixedRightSlideViewLengthIfCentered;

@property (nonatomic, assign) id<VSSlidingViewControllerDelegate> delegate;

@property (nonatomic, assign) VSSlidingViewControllerTopViewPosition currentTopViewPosition;

@property (nonatomic, assign) VSSlidingViewControllerAnchoredGesture topViewAnchoredGestureMask;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer* panGesture;
@property (nonatomic, strong, readonly) UITapGestureRecognizer* resettingTapGesture;
@property (nonatomic, strong) NSArray* customAnchoredGestureArray;

@property (nonatomic, assign) NSTimeInterval defaultTransitionDuration;

+ (instancetype) slidingViewController;

- (void) anchorTopViewToLeftAnimated: (BOOL)animated;
- (void) anchorTopViewToLeftAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;
- (void) anchorTopViewToRightAnimated: (BOOL)animated;
- (void) anchorTopViewToRightAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;
- (void) resetTopViewAnimated: (BOOL)animated;
- (void) resetTopViewAnimated: (BOOL)animated completionHandler: (void (^)())completionHandler;

@end


