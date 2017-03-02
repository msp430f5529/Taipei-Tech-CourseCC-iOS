//
//  AccountViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/1.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UIBarButtonItem *sidebarButton;
    
    IBOutlet UITextField *studentID;
    IBOutlet UITextField *password;
}

@end
