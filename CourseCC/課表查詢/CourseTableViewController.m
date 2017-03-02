//
//  CourseTableViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/1.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseTableViewController.h"
#import "SWRevealViewController.h"
#import "HttpPost.h"
#import "OCRNportal.h"
#import "DataAbstract.h"
#import "CourseDataModel.h"

@interface CourseTableViewController ()
{
    HttpPost *client;
    
    int currentStage;
    NSString *cookieValue;
    NSString *sessionID;
    
    NSString *myStudentID;
    NSString *myPassword;
    
    NSString *userName;
    
    int failCount;
    
    BOOL isLoggedIn;
    
    BOOL isInProcess;
    
    NSMutableArray *yearCourses;
    NSMutableArray *semesterTitle;
    NSArray *courses;
    
    int currentSemester;
    
    int terminatedCount;
    
    int errLoginCount;
}
@end

@implementation CourseTableViewController

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
    
    //ScrollView Properties
    scrollViewOfCourse.backgroundColor = [UIColor whiteColor];
    scrollViewOfCourse.delegate = self;
    scrollViewOfCourse.contentSize = CGSizeMake(360, 500);
    scrollViewOfCourse.directionalLockEnabled = YES;
    [scrollViewOfCourse setShowsHorizontalScrollIndicator:NO];
    [scrollViewOfCourse setShowsVerticalScrollIndicator:NO];
    
    scrollViewOfClassPeriod.backgroundColor = [UIColor whiteColor];
    scrollViewOfClassPeriod.delegate = self;
    scrollViewOfClassPeriod.contentSize = CGSizeMake(30, 500);
    scrollViewOfClassPeriod.directionalLockEnabled = YES;
    [scrollViewOfClassPeriod setShowsHorizontalScrollIndicator:NO];
    [scrollViewOfClassPeriod setShowsVerticalScrollIndicator:NO];
    
    scrollViewOfWeekday.backgroundColor = [UIColor whiteColor];
    scrollViewOfWeekday.delegate = self;
    scrollViewOfWeekday.contentSize = CGSizeMake(360, 30);
    scrollViewOfWeekday.directionalLockEnabled = YES;
    
    //TextField Properties
    textfieldOfStudentID.layer.borderWidth = 2.0f;
    textfieldOfStudentID.layer.borderColor = borderColor.CGColor;
    textfieldOfStudentID.layer.cornerRadius = 10.0f;
    textfieldOfStudentID.delegate = self;

    //Initialize Function
    [self constructColorArray];
    [self createCourseButton];
    [self constructLabelOfPeriod];
    [self constructLabelOfWeek];
    [self initializeBtn];
    
    errLoginCount = 0;
    
    [self retreiveAccountDataFromFile];
    [self loadCoursesFromFile];
    
    //Notification of App Enter Background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    isLoggedIn = NO;
    currentSemester = 0;
    isInProcess = NO;
    [self activityIndicatorSwitch:NO];
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

- (void) activityIndicatorSwitch:(BOOL)isActive
{
    isInProcess = isActive;
    activityIndicator.hidden = !isActive;
    activityIndicatorCover.hidden = !isActive;
    self.view.userInteractionEnabled = !isActive;
    
    if (isActive) {
        [activityIndicator startAnimating];
    }
    else
    {
        [activityIndicator stopAnimating];
    }
}

-(void)loadCoursesFromFile
{
    [self initializeBtn];
    
    CourseDataModel *model = [[CourseDataModel alloc] init];
    if ([myStudentID isEqualToString:textfieldOfStudentID.text]) {
        courses = [[NSArray alloc] initWithArray:[[model readCoursesFromFile:YES] objectAtIndex:currentSemester] copyItems:YES];
        semesterTitle = [[NSMutableArray alloc] initWithArray:[model readCoursesTitleFromFile:YES] copyItems:YES];
    }
    else
    {
        courses = [[NSArray alloc] initWithArray:[[model readCoursesFromFile:NO] objectAtIndex:currentSemester] copyItems:YES];
        semesterTitle = [[NSMutableArray alloc] initWithArray:[model readCoursesTitleFromFile:NO] copyItems:YES];
    }
    
    int count = 0;
    for (NSDictionary *course in courses) {
        if (![[course objectForKey:@"Course-Withdraw"] isEqualToString:@"Y"]) {
            for (NSString *coursePeriod in [course objectForKey:@"Class-Period"]) {
                UIButton *myButton = (UIButton *)[scrollViewOfCourse viewWithTag:[coursePeriod integerValue]];
                if ([[course objectForKey:@"Course-Name"] length] >= 4)
                {
                    [myButton setTitle:[[course objectForKey:@"Course-Name"] substringToIndex:4] forState:UIControlStateNormal];
                }
                else
                {
                    [myButton setTitle:[[course objectForKey:@"Course-Name"] substringToIndex:2] forState:UIControlStateNormal];
                }
                [myButton setTitleColor:[colorArray objectAtIndex:count] forState:UIControlStateNormal];
                myButton.hidden = NO;
                UILabel *border = (UILabel *)[scrollViewOfCourse viewWithTag:[coursePeriod integerValue] * 1000];
                border.hidden = NO;
            }
            count++;
        }
    }
}

#pragma mark - Initialize Function

- (void)createCourseButton
{
    for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 13; j++) {
            UIButton *courseBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [courseBtn setTitle:@"Button" forState:UIControlStateNormal];\
            courseBtn.titleLabel.minimumScaleFactor = 0.5;
            courseBtn.titleLabel.font = [UIFont fontWithName:@"Heiti TC" size:(9.5)];
            courseBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            courseBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [courseBtn addTarget:self action:@selector(touchCourseInfo:) forControlEvents:UIControlEventTouchUpInside];
            courseBtn.frame = CGRectMake((i * 50), (0.0 + j * 38), 42.0, 30.0);
            courseBtn.tag = (13 * i) + (j + 1);
            courseBtn.hidden = YES;
            
            UILabel *borderOfCourseBtn = [[UILabel alloc] initWithFrame:CGRectMake((i * 50), (0.0 + j * 38), 42.0, 30.0)];
            UIColor *borderColor = [UIColor colorWithRed:175/255.0 green:175/255.0 blue:175/255.0 alpha:0.9];
            
            borderOfCourseBtn.layer.borderColor = borderColor.CGColor;
            borderOfCourseBtn.layer.borderWidth = 2.0f;
            borderOfCourseBtn.layer.cornerRadius = 10.0f;
            //borderOfCourseBtn.hidden = NO;
            borderOfCourseBtn.tag = ((13 * i) + (j + 1)) * 1000;
            
            [scrollViewOfCourse addSubview:borderOfCourseBtn];
            [scrollViewOfCourse addSubview:courseBtn];
        }
    }
}

- (void)initializeBtn
{
    for (int i = 1; i <= 91; i++) {
        UIButton *myButton = (UIButton *)[scrollViewOfCourse viewWithTag:i];
        [myButton setTitle:NULL forState:UIControlStateNormal];
        myButton.hidden = YES;
        UILabel *border = (UILabel *)[scrollViewOfCourse viewWithTag:i * 1000];
        border.hidden = YES;
    }
}

- (void)constructLabelOfWeek
{
    for (int i = 0; i < 7; i++) {
        UILabel *peroidLabel = [[UILabel alloc]initWithFrame:CGRectMake(i * 50, 4, 42, 30)];
        peroidLabel.textAlignment =  NSTextAlignmentCenter;
        peroidLabel.textColor = [UIColor blackColor];
        peroidLabel.backgroundColor = [UIColor whiteColor];
        switch (i + 1) {
            case 1:
                peroidLabel.text = [NSString stringWithFormat: @"一"];
                break;
            case 2:
                peroidLabel.text = [NSString stringWithFormat: @"二"];
                break;
            case 3:
                peroidLabel.text = [NSString stringWithFormat: @"三"];
                break;
            case 4:
                peroidLabel.text = [NSString stringWithFormat: @"四"];
                break;
            case 5:
                peroidLabel.text = [NSString stringWithFormat: @"五"];
                break;
            case 6:
                peroidLabel.text = [NSString stringWithFormat: @"六"];
                break;
            case 7:
                peroidLabel.text = [NSString stringWithFormat: @"日"];
                break;
            default:
                peroidLabel.text = [NSString stringWithFormat: @"%d", (i+1)];
                break;
        }
        [scrollViewOfWeekday addSubview:peroidLabel];
    }
    
}

- (void)constructLabelOfPeriod
{
    for (int i = 0; i < 13; i++) {
        UILabel *peroidLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, (0 + i*38), 30, 30)];
        peroidLabel.textAlignment =  NSTextAlignmentCenter;
        peroidLabel.textColor = [UIColor blackColor];
        peroidLabel.backgroundColor = [UIColor whiteColor];
        peroidLabel.font = [UIFont fontWithName:@"Heiti TC" size:(17.0)];
        switch (i + 1) {
            case 10:
                peroidLabel.text = [NSString stringWithFormat: @"A"];
                break;
            case 11:
                peroidLabel.text = [NSString stringWithFormat: @"B"];
                break;
            case 12:
                peroidLabel.text = [NSString stringWithFormat: @"C"];
                break;
            case 13:
                peroidLabel.text = [NSString stringWithFormat: @"D"];
                break;
            default:
                peroidLabel.text = [NSString stringWithFormat: @"%d", (i+1)];
                break;
        }
        [scrollViewOfClassPeriod addSubview:peroidLabel];
    }
}

- (void)constructColorArray
{
    colorArray = [[NSMutableArray alloc] initWithObjects:[UIColor blueColor],[UIColor redColor],[UIColor orangeColor],[UIColor purpleColor],[UIColor brownColor],[UIColor grayColor],[UIColor magentaColor],[UIColor colorWithRed:55/255.0 green:109/255.0 blue:109/255.0 alpha:1.0],[UIColor colorWithRed:40/255.0 green:154/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:129/255.0 green:57/255.0 blue:58/255.0 alpha:1.0],[UIColor colorWithRed:70/255.0 green:140/255.0 blue:140/255.0 alpha:1.0],[UIColor colorWithRed:253/255.0 green:205/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:151/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:82/255.0 green:72/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:54/255.0 green:51/255.0 blue:131/255.0 alpha:1.0],[UIColor colorWithRed:88/255.0 green:159/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:252/255.0 green:215/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:205/255.0 green:183/255.0 blue:181/255.0 alpha:1.0],[UIColor colorWithRed:30/255.0 green:144/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:205/255.0 green:16/255.0 blue:118/255.0 alpha:1.0],[UIColor colorWithRed:139/255.0 green:0/255.0 blue:0/255.0 alpha:1.0],[UIColor colorWithRed:238/255.0 green:233/255.0 blue:191/255.0 alpha:1.0],[UIColor colorWithRed:131/255.0 green:111/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:72/255.0 green:118/255.0 blue:255/255.0 alpha:1.0],[UIColor colorWithRed:74/255.0 green:112/255.0 blue:139/255.0 alpha:1.0], nil];
    
    //NSLog(@"colorObject: %@ with %lu objects", colorArray, (unsigned long)[colorArray count]);
}

#pragma mark - Error Function

- (void) showErrorWithErrorCode:(int)errCode
{
    switch (errCode) {
        case 200:
        {
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統提示"
                                                              message:@"課表查詢成功"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 404:
        {
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"課表查詢失敗，請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 997:
        {
            isLoggedIn = NO;
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"帳號已被鎖住"
                                                              message:@"請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 998:
        {
            isLoggedIn = NO;
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                              message:@"請檢查帳號密碼"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 999:
        {
            isLoggedIn = NO;
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統不穩定"
                                                              message:@"請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Save/Retrieve Function

- (void)saveAccountDataToFile {
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/StudentID.plist"];
    //Dictionary
    NSMutableDictionary *accountDict = [[NSMutableDictionary alloc] init];
    [accountDict setObject:textfieldOfStudentID.text forKey:@"StuduntID"];
    
    //Save Data
    [accountDict writeToFile:filePath atomically:YES];
    
    //File Path
    filePath = [documentFolder stringByAppendingFormat:@"/errorLoginCount.plist"];
    //Dictionary
    accountDict = [[NSMutableDictionary alloc] init];
    [accountDict setObject:[NSString stringWithFormat:@"%d", errLoginCount] forKey:@"errLoginCount"];
    
    //Save Data
    [accountDict writeToFile:filePath atomically:YES];
    
    //File Path
    filePath = [documentFolder stringByAppendingFormat:@"/UserName.plist"];
    //Dictionary
    accountDict = [[NSMutableDictionary alloc] init];
    
    //Save Data
    if (![userName isEqualToString:@""] && userName != nil) {
        [accountDict setObject:userName forKey:@"User-Name"];
        [accountDict writeToFile:filePath atomically:YES];
    }

}

- (void)retreiveAccountDataFromFile {
    //Get Text Input
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/StudentID.plist"];
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *accountDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        textfieldOfStudentID.text = [accountDict objectForKey:@"StuduntID"];
    }
    
    
    //Get User Account
    //File Path
    path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentFolder = [path objectAtIndex:0];
    filePath = [documentFolder stringByAppendingFormat:@"/myAccount.plist"];
    
    //Check if the file exists
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *accountDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        myStudentID = [accountDict objectForKey:@"StuduntID"];
        myPassword = [accountDict objectForKey:@"Password"];
    }
    else
    {
        myStudentID = @"";
        myPassword = @"";
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


#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    
    if([scrollView isEqual:scrollViewOfCourse])
    {
        CGPoint offsetX = scrollViewOfWeekday.contentOffset;
        offsetX.x = scrollView.contentOffset.x;
        [scrollViewOfWeekday setContentOffset:offsetX];
        
        CGPoint offsetY = scrollViewOfClassPeriod.contentOffset;
        offsetY.y = scrollView.contentOffset.y;
        [scrollViewOfClassPeriod setContentOffset:offsetY];
    }
    else if([scrollView isEqual:scrollViewOfWeekday])
    {
        CGPoint offsetX = scrollViewOfCourse.contentOffset;
        offsetX.x = scrollView.contentOffset.x;
        [scrollViewOfCourse setContentOffset:offsetX];
    }
    else if([scrollView isEqual:scrollViewOfClassPeriod])
    {
        CGPoint offsetY = scrollViewOfCourse.contentOffset;
        offsetY.y = scrollView.contentOffset.y;
        [scrollViewOfCourse setContentOffset:offsetY];
        
    }
    
}

#pragma mark - IBAction (Touch Function)

- (IBAction)touchActionSheet:(UIBarButtonItem *)sender {
    if (courses != NULL && isInProcess == NO) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"變更學期"
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        if (![textfieldOfStudentID.text isEqualToString:myStudentID]) {
            [actionSheet addButtonWithTitle:@"回到我的課表"];
            actionSheet.tag = 100;
        }
        else
        {
            actionSheet.tag = 200;
        }
        
        for(NSString *title in semesterTitle)  {
            [actionSheet addButtonWithTitle:title];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        [actionSheet showInView:self.view];
    }
    else if([textfieldOfStudentID.text length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注意"
                                                        message:@"請先輸入學號查詢課表"
                                                       delegate:nil
                                              cancelButtonTitle:@"確定"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

- (void)touchCourseInfo:(UIButton *)sender
{
    NSString *courseInfoStr = @"";
    for (NSDictionary *course in courses) {
        for (NSString *coursePeriod in [course objectForKey:@"Class-Period"]) {
            if (sender.tag == [coursePeriod integerValue]) {
                NSString *teacherInfo = @"";
                NSString *classroomInfo = @"";
                
                for (int i = 0; i < [[course objectForKey:@"Course-Teacher"] count]; i++) {
                    teacherInfo = [teacherInfo stringByAppendingString:[[course objectForKey:@"Course-Teacher"] objectAtIndex:i]];
                    if (i != [[course objectForKey:@"Course-Teacher"] count] - 1) {
                        teacherInfo = [teacherInfo stringByAppendingString:@","];
                    }
                }
                
                for (int i = 0; i < [[course objectForKey:@"Course-Classroom"] count]; i++) {
                    classroomInfo = [classroomInfo stringByAppendingString:[[course objectForKey:@"Course-Classroom"] objectAtIndex:i]];
                    if (i != [[course objectForKey:@"Course-Classroom"] count] - 1) {
                        classroomInfo = [classroomInfo stringByAppendingString:@","];
                    }
                }
                
                if ([[course objectForKey:@"Course-Name"] isEqualToString:@"體育"])
                {
                    courseInfoStr = [NSString stringWithFormat:@"課程名稱：%@\n教師：%@\n備註：%@\n", [course objectForKey:@"Course-Name"], teacherInfo, [course objectForKey:@"Course-Memo"]];
                }
                else
                {
                    courseInfoStr = [NSString stringWithFormat:@"課程名稱：%@\n教師：%@\n教室：%@\n", [course objectForKey:@"Course-Name"], teacherInfo, classroomInfo];
                }
                UIAlertView *courseInfo = [[UIAlertView alloc] initWithTitle:@"課程資訊"
                                                                     message:courseInfoStr
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                [courseInfo show];
                break;
            }
        }
    }
    
}

- (IBAction)touchSearchBtn:(UIButton *)sender {
    
    [textfieldOfStudentID resignFirstResponder];
    [self activityIndicatorSwitch:YES];
    
    if ([textfieldOfStudentID.text isEqualToString:@""]) {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                          message:@"請先輸入學號"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];

    }
    else if (![self checkInputData])
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                          message:@"請輸入有效學號"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];
        
    }
    else if (![self checkInternet])
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                          message:@"請檢查網路設定"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];

    }
    else if ([myStudentID isEqualToString:@""] || [myPassword isEqualToString:@""])
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                          message:@"請先到帳號設定頁面設定帳號"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];
    }
    else if (errLoginCount == 4)
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"警告"
                                                          message:@"請先到帳號設定頁面確認密碼設定"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];
    }
    else if (errLoginCount == 5)
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"警告"
                                                          message:@"請先到帳號設定頁面確認密碼設定"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];
    }
    else
    {
        isInProcess = YES;
        if (isLoggedIn) {
            [self fetchDataWithStudentID:textfieldOfStudentID.text];
        }
        else
        {
            terminatedCount = 0;
            [self startFetchingFunctionWithLogin];
        }
    }
}

- (void)startFetchingFunctionWithLogin
{
    if (terminatedCount < 10) {
        NSString *URL = @"http://nportal.ntut.edu.tw/authImage.do";
        NSURL *url = [NSURL URLWithString:URL];
        client = [[HttpPost alloc] initWithURL:url postData:@"" cookie:@"" timeout:5 delegate:self];
        [client startDownloadWithURL:url postData:@"" cookie:@""];
        currentStage = 0;
        yearCourses = [[NSMutableArray alloc] init];
    }
    else{
        [self showErrorWithErrorCode:999];
    }
}

#pragma mark - Fetching Check

- (BOOL)checkInternet
{
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://luthertsai.com"] encoding:NSUTF8StringEncoding error:nil];
    BOOL checkFlag;
    
    if (connect == NULL) {
        checkFlag = FALSE;
    }
    else {
        checkFlag = TRUE;
    }
    return checkFlag;
}

- (BOOL) checkInputData
{
    if ([textfieldOfStudentID.text length] == 9 || [textfieldOfStudentID.text length] == 8) {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - HTTP Post Delegate

- (void) httpPost:(HttpPost *)httpPost didReceiveResponseWithCookie:(NSString *)responseCookie
{
    if (![responseCookie isEqualToString:@""]) {
        cookieValue = responseCookie;
        NSLog(@"CURRENT STAGE: %d COOKIE => %@", currentStage ,cookieValue);
    }
}

- (void) httpPost:(HttpPost *)httpPost didFinishWithData:(NSData *)fileData
{
    //NSLog(@"%@", fileData);
    switch (currentStage) {
        case 0:
        {
            UIImage *authImage = [[UIImage alloc] initWithData:fileData];
            OCRNportal *OCR = [[OCRNportal alloc] init];
            if (authImage != nil) {
                NSString *authCode = [OCR OCRnPortalWithImage:authImage];
                
                NSString *post = [NSString stringWithFormat:@"muid=%@&mpassword=%@&authcode=%@&Submit2=%@",myStudentID,myPassword, authCode, @"登入（Login）"];
                
                NSString *URL = @"http://nportal.ntut.edu.tw/login.do";
                NSURL *url = [NSURL URLWithString:URL];
                client = [[HttpPost alloc] initWithURL:url postData:post cookie:cookieValue timeout:15 delegate:self];
                [client startDownloadWithURL:url postData:post cookie:cookieValue];
                
                currentStage = 1;

            }
            else
            {
                [self performSelector:@selector(startFetchingFunctionWithLogin) withObject:nil afterDelay:1.0];
            }
        }
            break;
        case 1:
        {
            NSString* newStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", newStr);
            NSString *szNeedle= @"\"success\" : true";
            NSRange range = [newStr rangeOfString:szNeedle];
            if (range.location == NSNotFound)
            {
                szNeedle= @"帳號或密碼錯誤";
                range = [newStr rangeOfString:szNeedle];
                if (range.location != NSNotFound)
                {
                    szNeedle= @"累積連續錯誤次數：";
                    range = [newStr rangeOfString:szNeedle];
                    if (range.location != NSNotFound) {
                        errLoginCount = (int)[[[newStr substringFromIndex:range.length + range.location] substringToIndex:1] integerValue];
                    }
                    [self showErrorWithErrorCode:998];
                }
                else {
                    szNeedle= @"帳號已被鎖住";
                    range = [newStr rangeOfString:szNeedle];
                    errLoginCount = 5;
                    if (range.location != NSNotFound) {
                        [self showErrorWithErrorCode:997];
                    }
                }
            }
            else
            {
                errLoginCount = 0;
                szNeedle= @"\"givenName\" : \"";
                range = [newStr rangeOfString:szNeedle];
                newStr = [newStr substringFromIndex:range.length + range.location];
                szNeedle= @"\",";
                range = [newStr rangeOfString:szNeedle];
                userName = [newStr substringToIndex:range.location];
                                
                NSString *URL = @"http://nportal.ntut.edu.tw/ssoIndex.do?apUrl=http://aps.ntut.edu.tw/course/tw/courseSID.jsp&apOu=aa_0010&sso=big5&datetime1=1382683005121";
                NSURL *url = [NSURL URLWithString:URL];
                failCount = 0;
                [client startDownloadWithURL:url postData:nil cookie:cookieValue];
                currentStage++;
            }
        }
            break;
        case 2:
        {
            NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSString *dataContent = [[NSString alloc] initWithData:fileData encoding:strEncode];
            //NSLog(@"%@", dataContent);
            
            NSString *szNeedle= @"<input type='hidden' name='sessionId' value='";
            NSRange range = [dataContent rangeOfString:szNeedle];
            
            if (range.location == NSNotFound) {
                if (failCount > 100) {
                    currentStage = 999;
                }
                else
                {
                    NSString *URL = @"http://nportal.ntut.edu.tw/ssoIndex.do?apUrl=http://aps.ntut.edu.tw/course/tw/courseSID.jsp&apOu=aa_0010&sso=big5&datetime1=1382683005121";
                    NSURL *url = [NSURL URLWithString:URL];
                    
                    [client startDownloadWithURL:url postData:nil cookie:cookieValue];
                    failCount++;
                }
            }
            else
            {
                NSInteger idx = range.location + range.length;
                NSString *sessionId = [dataContent substringFromIndex:idx];
                szNeedle= @"'>";
                range = [sessionId rangeOfString:szNeedle];
                idx = range.location;
                sessionID = [sessionId substringToIndex:idx];
                
                NSString *URL = @"http://aps.ntut.edu.tw/course/tw/courseSID.jsp";
                NSURL *url = [NSURL URLWithString:URL];
                
                NSString *post = [NSString stringWithFormat:@"sessionId=%@&userid=%@&userType=%@", sessionID ,myStudentID, @"50"];
                [client startDownloadWithURL:url postData:post cookie:cookieValue];
                currentStage++;
            }
        }
            break;
        case 3:
        {
            
            NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
            NSString *dataContent = [[NSString alloc] initWithData:fileData encoding:strEncode];
            NSLog(@"%@", dataContent);
            
            NSString *szNeedle= @"無法連結至 Portal 主機進行使用者身分認證";
            NSRange range = [dataContent rangeOfString:szNeedle];

            if (range.location == NSNotFound) {
                isLoggedIn = YES;
                
                //[self fetchDataWithStudentID:textfieldOfStudentID.text];
                [self getCourseDataWithStudentID:textfieldOfStudentID.text Year:@"103" Semester:@"2"];
                currentStage++;
            }
            else
            {
                isLoggedIn = NO;
                [self performSelector:@selector(startFetchingFunctionWithLogin) withObject:nil afterDelay:3.0];
            }
            
        }
            break;
        case 4:
        {
            //NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
            NSString *dataContent = [[NSString alloc] initWithData:fileData encoding:big5];
            NSLog(@"%@", dataContent);
            NSString *szNeedle= @"查無該學號的學生基本資料";
            NSRange range = [dataContent rangeOfString:szNeedle];
            
            if (range.location != NSNotFound) {
                UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                                  message:@"請輸入有效學號"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
                [caution show];
                [self activityIndicatorSwitch:NO];
            }
            else
            {
                [self fetchDataWithStudentID:textfieldOfStudentID.text];
            }
        }
            break;
        case 5:
        {
            NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
            NSString *dataContent = [[NSString alloc] initWithData:fileData encoding:big5];
            //NSLog(@"%@", dataContent);
            DataAbstract *abstractor = [[DataAbstract alloc] init];
            [yearCourses addObject:[abstractor outputCoursesWithData:dataContent]];
            NSLog(@"XD");
            currentStage++;
        }
            break;
        case 999:
        {
            isLoggedIn = NO;
            [self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統不穩定"
                                                              message:@"請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        default:
            break;
    }
}

- (void) httpPost:(HttpPost *)httpPost didFailWithError:(NSError *)error
{
    //NSLog(@"%@", error);
    isLoggedIn = NO;
    [self activityIndicatorSwitch:NO];
    UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統不穩定"
                                                      message:@"請稍後再試"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [caution show];
}

- (void)fetchDataWithStudentID:(NSString *)studentId
{
    yearCourses = [[NSMutableArray alloc] init];
    int waitTime = 0;
    int semesterCount = 0;
    semesterTitle = [[NSMutableArray alloc] init];
    if ([studentId length] == 9) {
        for (int i = 104; i >= [[studentId substringToIndex:3] integerValue]; i--) {
            for (int j = 0; j < 2; j++) {
                if (i == 104 && j == 1) {
                    waitTime += 3;
                    semesterCount++;
                    [semesterTitle addObject:[NSString stringWithFormat:@"%d學年 第%d學期",i,(2 - j)]];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"1"];
                        //NSLog(@"NEW");
                        currentStage = 5;
                    });
                }
                else if (i != 104)
                {
                    waitTime += 3;
                    semesterCount++;
                    [semesterTitle addObject:[NSString stringWithFormat:@"%d學年 第%d學期",i,(2 - j)]];
                    switch (j) {
                        case 0:
                        {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"2"];
                                //NSLog(@"NEW");
                                currentStage = 5;
                            });
                        }
                            break;
                        case 1:
                        {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"1"];
                                //NSLog(@"NEW");
                                currentStage = 5;
                            });
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
    else if([studentId length] == 8)
    {
        for (int i = 104; i >= [[studentId substringToIndex:2] integerValue]; i--) {
            for (int j = 0; j < 2; j++) {
                if (i == 104 && j == 1) {
                    waitTime += 3;
                    semesterCount++;
                    [semesterTitle addObject:[NSString stringWithFormat:@"%d學年 第%d學期",i,(2 - j)]];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"1"];
                        //NSLog(@"NEW");
                        currentStage = 5;
                    });
                }
                else if (i != 104)
                {
                    waitTime += 3;
                    semesterCount++;
                    [semesterTitle addObject:[NSString stringWithFormat:@"%d學年 第%d學期",i,(2 - j)]];
                    switch (j) {
                        case 0:
                        {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"2"];
                                //NSLog(@"NEW");
                                currentStage = 5;
                            });
                        }
                            break;
                        case 1:
                        {
                            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (waitTime - 3) * NSEC_PER_SEC);
                            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                [self getCourseDataWithStudentID:studentId Year:[NSString stringWithFormat:@"%d", i] Semester:@"1"];
                                //NSLog(@"NEW");
                                currentStage = 5;
                            });
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([yearCourses count] == semesterCount) {
            //NSLog(@"%@\n", yearCourses);
            CourseDataModel *model = [[CourseDataModel alloc] init];
            [model storeMyCourseWithYearCourses:yearCourses myCourse:[myStudentID isEqualToString:textfieldOfStudentID.text]];
            [model storeMyCourseWithYearCoursesTitle:semesterTitle myCourse:[myStudentID isEqualToString:textfieldOfStudentID.text]];
            [self initializeBtn];
            [self loadCoursesFromFile];
            [self activityIndicatorSwitch:NO];
            [self showErrorWithErrorCode:200];
        }
        else {
            [self activityIndicatorSwitch:NO];
            [self showErrorWithErrorCode:404];
        }
    });
}

-(void)getCourseDataWithStudentID:(NSString *)stuID Year:(NSString *)year Semester:(NSString *)sem
{
    //第一步驟所建立的頁面url
    NSString *urlPath  = [NSString stringWithFormat:@"http://aps.ntut.edu.tw/course/tw/Select.jsp?format=-2&code=%@&year=%@&sem=%@", stuID, year, sem];
    NSURL *url = [NSURL URLWithString:urlPath];
    [client startDownloadWithURL:url postData:nil cookie:cookieValue];
}

#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 100) {
        NSInteger cancelBtnIndex = [semesterTitle count] + 1;
        
        if (buttonIndex == 0) {
            textfieldOfStudentID.text = myStudentID;
            currentSemester = 0;
        }
        else if (buttonIndex != cancelBtnIndex)
        {
            currentSemester = (int)(buttonIndex - 1);
        }
    }
    else if (actionSheet.tag == 200)
    {
        NSInteger cancelBtnIndex = [semesterTitle count];
        if (buttonIndex != cancelBtnIndex)
        {
            currentSemester = (int)buttonIndex;
        }
    }
    [self initializeBtn];
    [self loadCoursesFromFile];
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
