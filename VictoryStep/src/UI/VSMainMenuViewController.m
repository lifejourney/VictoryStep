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
@property (nonatomic, strong) NSArray* itemByCategoryArray;

@end

@implementation VSMainMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuSectionArray = @[@"Category", @"Tag"];
    self.itemByCategoryArray = @[@"Cycle", @"Once"];
    self.itemByTagArray = @[@"Project", @"Health", @"Touch"];
    
    self.tableView.sectionHeaderHeight = 50;
    
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
    NSInteger count = 0;
    
    if (section < [self.menuSectionArray count])
    {
        NSString* sectionName = [self.menuSectionArray objectAtIndex: section];
        
        if ([sectionName isEqualToString: @"Category"])
            count = [self.itemByCategoryArray count];
        else if ([sectionName isEqualToString: @"Tag"])
            count = [self.itemByTagArray count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = CGRectZero;
    frame.size.height = 40;
    frame.size.width = self.view.frame.size.width;
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame: frame];
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = [self.itemByCategoryArray objectAtIndex: indexPath.row];
            break;
            
        case 1:
            cell.textLabel.text = [self.itemByTagArray objectAtIndex: indexPath.row];
            break;
            
        default:
            break;
    }
        
    return cell;
}

- (CGFloat) tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return 20;
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

@end
