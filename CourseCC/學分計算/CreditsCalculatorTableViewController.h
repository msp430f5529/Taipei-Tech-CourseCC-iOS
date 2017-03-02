//
//  CreditsCalculatorTableViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface CreditsCalculatorTableViewController : UITableViewController <HttpPostDelegate, UIAlertViewDelegate>
{
    IBOutlet UIBarButtonItem *sidebarButton;
    
    IBOutlet UILabel *HeaderTitleLabel;
    IBOutlet UILabel *HeaderInfoLabel;
    IBOutlet UIButton *HeaderButton;
    
    IBOutlet UILabel *courseNumber;
    IBOutlet UILabel *courseName;
    IBOutlet UILabel *courseCredits;
    IBOutlet UIButton *courseType;
    IBOutlet UILabel *courseScore;
    IBOutlet UILabel *courseTypeLabel;
    
    IBOutlet UITableView *courseTable;
    
    IBOutlet UILabel *courseTypeTitleLabel;
    IBOutlet UILabel *courseTypeCredits;
    
    IBOutlet UILabel *departmentTitle;
    IBOutlet UILabel *departmentLabel;
    IBOutlet UIButton *departmentSelectionBtn;
    
    IBOutlet UILabel *graduationDownloadValue;
    IBOutlet UIProgressView *graduationDownloadProgress;
}
@end
