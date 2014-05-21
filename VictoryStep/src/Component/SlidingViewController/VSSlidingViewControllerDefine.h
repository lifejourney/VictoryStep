//
//  VSSlidingViewControllerDefine.h
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//


UIKIT_EXTERN NSString* const kVSTransitionContextTopViewControllerKey;
UIKIT_EXTERN NSString* const kVSTransitionContextUnderViewControllerKey;

typedef NS_ENUM(NSInteger, VSSlidingViewControllerAnchorPosition)
{
    VSSlidingViewControllerAnchorPositionLeft,
    VSSlidingViewControllerAnchorPositionRight
};

typedef NS_ENUM(NSInteger, VSSlidingViewControllerTopViewPosition)
{
    VSSlidingViewControllerTopViewPositionAnchoredLeft,
    VSSlidingViewControllerTopViewPositionAnchoredRight,
    VSSlidingViewControllerTopViewPositionCentered
};

typedef NS_ENUM(NSInteger, VSSlidingViewControllerOperation)
{
    VSSlidingViewControllerOperationNone,
    VSSlidingViewControllerOperationAnchorToLeft,
    VSSlidingViewControllerOperationResetFromLeft,
    VSSlidingViewControllerOperationAnchorToRight,
    VSSlidingViewControllerOperationResetFromRight
};

typedef NS_OPTIONS(NSInteger, VSSlidingViewControllerAnchoredGesture)
{
    VSSlidingViewControllerAnchoredGestureNone      = 0,
    VSSlidingViewControllerAnchoredGesturePanning   = 1 << 0,
    VSSlidingViewControllerAnchoredGestureTapping   = 1 << 1,
    VSSlidingViewControllerAnchoredGestureCustom    = 1 << 2,
    VSSlidingViewControllerAnchoredGestureDisabled  = 1 << 3
};