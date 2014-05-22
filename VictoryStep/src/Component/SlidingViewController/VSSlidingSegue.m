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
        //TO-DO: ??
        //if (slidingViewController.leftSlideViewController isMemberOfClass: [destinationViewController class])
        if (slidingViewController.leftSlideViewController == destinationViewController)
        {
            [slidingViewController anchorTopViewToRightAnimated: YES];
        }
        else if (slidingViewController.rightSlideViewController == destinationViewController)
        {
            [slidingViewController anchorTopViewToLeftAnimated: YES];
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
