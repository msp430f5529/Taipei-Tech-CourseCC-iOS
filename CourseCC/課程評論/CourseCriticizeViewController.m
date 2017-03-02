//
//  CourseCriticizeViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseCriticizeViewController.h"
#import "SWRevealViewController.h"
#import "CourseSearchTableViewController.h"

@interface CourseCriticizeViewController ()

@end

@implementation CourseCriticizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Sidebar Controller
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self->sidebarButton setTarget: self.revealViewController];
        [self->sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearchDetailSegue"])
    {
        CourseSearchTableViewController *vc = [segue destinationViewController];
        [vc setValue:teacherKeywordInput.text forKey:@"teacherKeyword"];
        [vc setValue:courseKeywordInput.text forKey:@"courseKeyword"];
    }
}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
