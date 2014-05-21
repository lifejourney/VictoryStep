//
//  VSSlidingSegue.m
//  VictoryStep
//
//  Created by Steven on 5/15/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSSlidingSegue.h"
#import "UIViewController+VSSlidingViewController.h"


@interface VSSlidingSegue ()

@property (nonatomic, assign) BOOL isUnwinding;

@end

@implementation VSSlidingSegue

- (id) initWithIdentifier: (NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination
{
    if (self == [super initWithIdentifier: identifier source: source destination: destination])
    {
        self.isUnwinding = NO;
        self.skipSettingTopViewController = NO;
    }
    
    return self;
}

- (void) perform
{
    VSSlidingViewController* slidingViewController = [[self sourceViewController] nearestAncestorSlidingViewController];
    UIViewController* destinationViewController = [self destinationViewController];
    
    if (self.isUnwinding)
    {
        if ([slidingViewController.underViewController isMemberOfClass: [destinationViewController class]])
        {
            switch (slidingViewController.anchorPosition)
            {
                case VSSlidingViewControllerAnchorPositionLeft:
                    [slidingViewController anchorTopViewToRightAnimated: YES];
                    
                    break;
                    
                case VSSlidingViewControllerAnchorPositionRight:
                    [slidingViewController anchorTopViewToLeftAnimated: YES];
                    
                    break;
                    
                default:
                    break;
            }
        }
    }
    else
    {
        if (!self.skipSettingTopViewController)
        {
            slidingViewController.topViewController = destinationViewController;
        }
        
        [slidingViewController resetTopViewAnimated: YES];
    }
}

@end
