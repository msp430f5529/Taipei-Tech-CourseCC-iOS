//
//  SidebarTableViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/1.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "CourseTableViewController.h"
#import "AccountViewController.h"

@interface SidebarTableViewController ()

@end

@implementation SidebarTableViewController
{
    NSArray *menuItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    menuItems = @[@"title", @"courseTable", @"schedule", @"creditsCalculator",@"discuss", @"meal", @"account"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];
    
    // Set the photo if it navigates to the PhotoView
    if ([segue.identifier isEqualToString:@"showAccount"]) {
        
    }
}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
