//
//  VSLocalStorage.h
//  VictoryStep
//
//  Created by Steven on 5/27/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSLocalStorage : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext* saveDedicatedMOC;
@property (nonatomic, strong, readonly) NSManagedObjectContext* viewDedicatedMOC;

- (BOOL) saveContext;

@end
