//
//  CourseCriticizeViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseCriticizeViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem *sidebarButton;
    
    IBOutlet UITextField *courseKeywordInput;
    IBOutlet UITextField *teacherKeywordInput;
}
@end
