//
//  SchoolScheduleViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/3.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface SchoolScheduleViewController : UIViewController <HttpPostDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UIBarButtonItem *sidebarButton;
    
    IBOutlet UILabel *currentMonthLabel;
    IBOutlet UIButton *nextMonthLabel;
    IBOutlet UIButton *previousMonthLabel;
    
    IBOutlet UITableView *scheduleTableView;
    
    NSArray *scheduleArray;
    
    IBOutlet UILabel *Date;
    IBOutlet UILabel *Weekday;
    IBOutlet UILabel *EventOfNTUT;
    
    int currentMonth;

    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *activityIndicatorCover;

}

@end
