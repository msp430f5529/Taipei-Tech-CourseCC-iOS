//
//  CourseDetailTableViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface CourseDetailTableViewController : UITableViewController <HttpPostDelegate, UIActionSheetDelegate>
{
    IBOutlet UIBarButtonItem *ActionButton;
    
    IBOutlet UILabel *HeaderTitle;
    IBOutlet UIImageView *LikeImage;
    IBOutlet UIImageView *DislikeImage;
    IBOutlet UILabel *LikeNumber;
    IBOutlet UILabel *DislikeNumber;
    
    IBOutlet UILabel *CourseDetailLabel;
    IBOutlet UILabel *CourseDetailContent;
    IBOutlet UITextView *CourseDescription;
    
    IBOutlet UITableView *CourseDetailTableView;
    
    IBOutlet UIImageView *CriticizeType;
    IBOutlet UITextView *CourseCriticize;
    IBOutlet UILabel *CourseCriticizeUser;
}

@property (nonatomic, strong) NSString *courseCode;
@property (nonatomic, strong) NSString *courseName;
@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSString *studentID;
@property (nonatomic, strong) NSString *studentName;
@property (nonatomic, strong) NSString *canCriticize;

@end
