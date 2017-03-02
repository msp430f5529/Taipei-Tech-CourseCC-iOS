//
//  CourseTableViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/1.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface CourseTableViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, HttpPostDelegate, UIActionSheetDelegate>
{
    IBOutlet UIBarButtonItem *sidebarButton;
    IBOutlet UITextField *textfieldOfStudentID;
    IBOutlet UIScrollView *scrollViewOfWeekday;
    IBOutlet UIScrollView *scrollViewOfClassPeriod;
    IBOutlet UIScrollView *scrollViewOfCourse;
    
    NSMutableArray *colorArray;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *activityIndicatorCover;
}
@end
