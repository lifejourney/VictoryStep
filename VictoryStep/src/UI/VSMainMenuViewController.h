//
//  VSMainMenuViewController.h
//  VictoryStep
//
//  Created by Steven on 5/21/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import <UIKit/UIKit.h>


@class VSMainMenuViewController;

typedef NS_ENUM(NSInteger, VSMainMenuItemType)
{
    VSMainMenuItemTypeAddTask,
    VSMainMenuItemTypeViewByTask,
    VSMainMenuItemTypeViewByStep,
    VSMainMenuItemTypeSetting
};

@protocol VSMainMenuViewControllerDelegate

@optional

- (void) mainMenuViewController: (VSMainMenuViewController*)viewController
            didSelectedItemType: (VSMainMenuItemType)itemType
                   selectedItem: (id)selectedItem;

@end


@interface VSMainMenuViewController : UITableViewController

@property (nonatomic, weak) NSObject<VSMainMenuViewControllerDelegate>* delegate;

@end
