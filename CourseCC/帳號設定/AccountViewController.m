//
//  AccountViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/1.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "AccountViewController.h"
#import "SWRevealViewController.h"

@interface AccountViewController ()
{
    int errLoginCount;
}
@end

@implementation AccountViewController

#pragma mark - ViewController Life Cycle

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
    
    UIColor *borderColor = [UIColor colorWithRed:87.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:0.9];
    
    //TextField Properties
    studentID.layer.borderWidth = 2.0f;
    studentID.layer.borderColor = borderColor.CGColor;
    studentID.layer.cornerRadius = 10.0f;
    studentID.delegate = self;
        
    password.layer.borderWidth = 2.0f;
    password.layer.borderColor = borderColor.CGColor;
    password.layer.cornerRadius = 10.0f;
    password.delegate = self;
    
    [self retreiveAccountDataFromFile];
    
    //Notification of App Enter Background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    
    if (errLoginCount == 4) {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統警告"
                                                          message:@"請務必確認密碼輸入正確，已累計四次錯誤登入"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        errLoginCount = 0;
    }
    else if (errLoginCount == 5) {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統警告"
                                                          message:@"請務必確認密碼輸入正確，已累計五次錯誤登入，帳號已被鎖定"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        errLoginCount = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveAccountDataToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveAccountDataToFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Save/Retrieve Function

- (void)saveAccountDataToFile {
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myAccount.plist"];
    
    //Dictionary
    NSMutableDictionary *accountDict = [[NSMutableDictionary alloc] init];
    [accountDict setObject:studentID.text forKey:@"StuduntID"];
    [accountDict setObject:password.text forKey:@"Password"];
    
    //Save Data
    [accountDict writeToFile:filePath atomically:YES];
    
    //File Path
    filePath = [documentFolder stringByAppendingFormat:@"/errorLoginCount.plist"];
    //Dictionary
    accountDict = [[NSMutableDictionary alloc] init];
    [accountDict setObject:[NSString stringWithFormat:@"%d", errLoginCount] forKey:@"errLoginCount"];
    
    //Save Data
    [accountDict writeToFile:filePath atomically:YES];
}

- (void)retreiveAccountDataFromFile {
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myAccount.plist"];
    
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *accountDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        studentID.text = [accountDict objectForKey:@"StuduntID"];
        password.text = [accountDict objectForKey:@"Password"];
    }
    
    //Get Error Times
    //File Path
    path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentFolder = [path objectAtIndex:0];
    filePath = [documentFolder stringByAppendingFormat:@"/errorLoginCount.plist"];
    
    //Check if the file exists
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *accountDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        errLoginCount = (int)[[accountDict objectForKey:@"errLoginCount"] integerValue];
    }
    else
    {
        errLoginCount = 0;
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
