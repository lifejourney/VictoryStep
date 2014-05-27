//
//  VSModelStepSeries.h
//  VictoryStep
//
//  Created by Steven on 5/27/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VSModelStepSeries : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * frequence;
@property (nonatomic, retain) NSDate * fromDate;
@property (nonatomic, retain) NSNumber * localID;
@property (nonatomic, retain) NSNumber * isOngoing;
@property (nonatomic, retain) NSNumber * dayNumber;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * timeZone;
@property (nonatomic, retain) NSDate * reminderTime;
@property (nonatomic, retain) NSString * reminderText;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * stepID;
@property (nonatomic, retain) NSNumber * syncStatus;

@end
