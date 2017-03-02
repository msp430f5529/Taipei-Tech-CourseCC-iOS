//
//  CourseSearchTableViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface CourseSearchTableViewController : UITableViewController <HttpPostDelegate, UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UILabel *commentNum;
    IBOutlet UIImageView *commentImg;
    IBOutlet UILabel *courseTeacher;
    IBOutlet UILabel *courseName;
    
    IBOutlet UITableView *searchResultTable;
}

@property (nonatomic, strong) NSString *teacherKeyword;
@property (nonatomic, strong) NSString *courseKeyword;

@end
