//
//  VSLocalStorage.m
//  VictoryStep
//
//  Created by Steven on 5/27/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSLocalStorage.h"
#import <CoreData/CoreData.h>
#import "UIDevice+VSUtility.h"


@interface VSLocalStorage ()

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* persistenStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel* managedObjectModel;

@end

@implementation VSLocalStorage

@synthesize saveDedicatedMOC=_saveDedicatedMOC, viewDedicatedMOC=_viewDedicatedMOC, persistenStoreCoordinator=_persistenStoreCoordinator, managedObjectModel = _managedObjectModel;

#pragma mark - Life cycle

- (instancetype) init
{
    if (self = [super init])
    {
        
    }
    
    return self;
}

#pragma mark - Properties

- (NSManagedObjectModel*) managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource: @"VictorySteps" withExtension: @"momd"];
        
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelURL];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*) persistenStoreCoordinator
{
    if (!_persistenStoreCoordinator)
    {
        NSURL *appDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
        NSURL *storeURL = [appDocumentsDirectory URLByAppendingPathComponent: @"VictorySteps.db"];
        
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setValue: @YES forKey: NSMigratePersistentStoresAutomaticallyOption];
        [options setValue: @YES forKey: NSInferMappingModelAutomaticallyOption];
        /* The default journal_mode "WAL" which is used since iOS 7 is not perfect as Apple says, we use the old one for now.
         * 1. http://stackoverflow.com/questions/20228486/core-data-sqlite-wal-file-gets-massive-7gb-when-inserting-5000-rows
         * 2. http://pablin.org/2013/05/24/problems-with-core-data-migration-manager-and-journal-mode-wal/
         */
        if ([UIDevice isIOS7orLater])
        {
            [options setValue: @{@"journal_mode": @"DELETE"} forKey: NSSQLitePragmasOption];
        }
        
        _persistenStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.managedObjectModel];
        
        NSError *error;
        
        if (![_persistenStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: options error: &error])
        {
            NSLog(@"Create local database fail: \n %@ \n%@", storeURL, error);
            
            /* From the apple's documentation: If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             Simply deleting the existing store:*/
            [[NSFileManager defaultManager] removeItemAtURL: storeURL error: &error];
            if (![_persistenStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: storeURL options: options error: &error])
            {
                NSLog(@"Create local database fail after remove the exist file:\n%@", error);
            }
        }
    }
    
    return _persistenStoreCoordinator;
}

- (NSManagedObjectContext*) saveDedicatedMOC
{
    if (!_saveDedicatedMOC)
    {
        _saveDedicatedMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        
        _saveDedicatedMOC.persistentStoreCoordinator = self.persistenStoreCoordinator;
    }
    
    return _saveDedicatedMOC;
}

- (NSManagedObjectContext*) viewDedicatedMOC
{
    if (!_viewDedicatedMOC)
    {
        _viewDedicatedMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        
        _viewDedicatedMOC.persistentStoreCoordinator = self.persistenStoreCoordinator;
    }
    
    return _viewDedicatedMOC;
}

#pragma mark - Public

- (BOOL) saveContext
{
    BOOL result = YES;
    
    if (_saveDedicatedMOC && [_saveDedicatedMOC hasChanges])
    {
        NSError *error;
        
        result = [_saveDedicatedMOC save: &error];
        
        if (!result)
        {
            NSLog(@"Save context fail: %@", error);
        }
    }
    
    return result;
}

#pragma mark - Private

@end






