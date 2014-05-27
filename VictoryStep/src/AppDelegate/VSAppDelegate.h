//
//  VSAppDelegate.h
//  VictoryStep
//
//  Created by Steven on 5/6/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSLocalStorage.h"


@interface VSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) VSLocalStorage *localStorage;

@end
