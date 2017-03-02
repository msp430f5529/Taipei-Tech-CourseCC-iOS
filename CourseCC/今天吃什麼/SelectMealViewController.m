//
//  SelectMealViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/10/20.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "SelectMealViewController.h"
#import "SWRevealViewController.h"
#import "DrawMealViewController.h"

@interface SelectMealViewController ()
{
    NSString *_selectionPlace;
    NSString *_selectionPrice;
    NSString *_selectionType;
}
@end

@implementation SelectMealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Sidebar Controller
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self->sideBarButton setTarget: self.revealViewController];
        [self->sideBarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

    _selectionPlace = @"任意";
    _selectionPrice = @"LOW";
    _selectionType = @"正餐";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISegmentedControl

- (IBAction)selectPlace:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            _selectionPlace = @"任意";
            break;
            
        case 1:
            _selectionPlace = @"光華";
            break;
            
        case 2:
            _selectionPlace = @"學校";
            break;
            
        case 3:
            _selectionPlace = @"新生";
            break;
            
        case 4:
            _selectionPlace = @"宿舍";
            break;
            
        case 5:
            _selectionPlace = @"市民大道";
            break;
            
        default:
            NSLog(@"Something Error");
            break;
    }
}

- (IBAction)selectPrice:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            _selectionPrice = @"LOW";
            break;
            
        case 1:
            _selectionPrice = @"MID";
            break;
            
        case 2:
            _selectionPrice = @"HIGH";
            break;
            
        default:
            NSLog(@"Something Error");
            break;
    }

}

- (IBAction)selectType:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            _selectionType = @"正餐";
            break;
            
        case 1:
            _selectionType = @"點心";
            break;
            
        default:
            NSLog(@"Something Error");
            break;
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"drawMealSegue"])
    {
        DrawMealViewController *vc = [segue destinationViewController];
        [vc setValue:_selectionPlace forKey:@"selectionPlace"];
        [vc setValue:_selectionPrice forKey:@"selectionPrice"];
        [vc setValue:_selectionType forKey:@"selectionType"];
    }

}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
