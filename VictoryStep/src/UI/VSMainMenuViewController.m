//
//  VSMainMenuViewController.m
//  VictoryStep
//
//  Created by Steven on 5/21/14.
//  Copyright (c) 2014 StevenZhuang. All rights reserved.
//

#import "VSMainMenuViewController.h"

@interface VSMainMenuViewController ()

@property (nonatomic, strong) NSArray* menuSectionArray;
@property (nonatomic, strong) NSArray* itemByTagArray;
@property (nonatomic, strong) NSArray* itemInNewArray;
@property (nonatomic, strong) NSArray* itemInViewArray;
@property (nonatomic, strong) NSArray* itemInSettingArray;

- (NSArray*) itemArrayForSection: (NSInteger)section;

@end

@implementation VSMainMenuViewController

- (instancetype) initWithStyle: (UITableViewStyle)style
{
    if (self = [super initWithStyle: style])
    {
        // Custom initialization
    }
    return self;
}

- (instancetype) init
{
    if (self = [self initWithStyle: UITableViewStyleGrouped])
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.allowsMultipleSelection = NO;
        
        self.view.backgroundColor = [UIColor clearColor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuSectionArray = @[@"New", @"View", @"Setting"];
    self.itemInNewArray = @[@"Task"];
    self.itemInViewArray = @[@"Tasks", @"Steps"];
    self.itemInSettingArray = @[@"Setting"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.menuSectionArray count];
}

- (NSString*) tableView: (UITableView *)tableView titleForHeaderInSection: (NSInteger)section
{
    return [self.menuSectionArray objectAtIndex: section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *itemArray = [self itemArrayForSection: section];
    
    return itemArray ? [itemArray count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectZero;
    frame.size.width = self.view.frame.size.width;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame: frame];
    
    NSArray *itemArray = [self itemArrayForSection: indexPath.section];
    
    cell.textLabel.text = itemArray ? [itemArray objectAtIndex: indexPath.row] : @"";
    
    if (itemArray != _itemInNewArray)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
 */

#pragma mark - Table view delegate

- (CGFloat) tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return 20;
}

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    NSArray *itemArray = [self itemArrayForSection: indexPath.section];
    
    if (self.delegate && [self.delegate respondsToSelector: @selector(mainMenuViewController:didSelectedItemType:selectedItem:)])
    {
        [self.delegate mainMenuViewController: self didSelectedItemType:<#(VSMainMenuItemType)#> selectedItem:<#(id)#>]
    }
}

#pragma mark - Private

- (NSArray*) itemArrayForSection: (NSInteger)section
{
    NSArray *itemArray;
    
    switch (section)
    {
        case 0:
            itemArray = _itemInNewArray;
            break;
            
        case 1:
            itemArray = _itemInViewArray;
            break;
            
        case 2:
            itemArray = _itemInSettingArray;
            break;
            
        default:
            itemArray = nil;
            break;
    }
    
    return itemArray;
}

@end
