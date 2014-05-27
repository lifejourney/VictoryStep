//
//  UIDevice+VSUtility.m
//  VictoryStep
//
//  Created by Steven on 5/27/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "UIDevice+VSUtility.h"

@implementation UIDevice (VSUtility)

+ (BOOL) isIOS7orLater
{
    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0;
}

@end
