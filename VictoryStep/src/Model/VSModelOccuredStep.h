//
//  VSModelOccuredStep.h
//  VictoryStep
//
//  Created by Steven on 5/27/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VSModelOccuredStep : NSManagedObject

@property (nonatomic, retain) NSString * stepID;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * stepDate;
@property (nonatomic, retain) NSDate * recordTime;
@property (nonatomic, retain) NSNumber * localID;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * stepStatus;

@end
