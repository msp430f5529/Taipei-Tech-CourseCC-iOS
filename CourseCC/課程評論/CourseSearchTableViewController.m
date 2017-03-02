//
//  CourseSearchTableViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseSearchTableViewController.h"
#import "CourseDetailTableViewController.h"

@interface CourseSearchTableViewController ()

@end

@implementation CourseSearchTableViewController
{
    HttpPost *client;
    int currentHTTPIndex;
    
    NSString *myStudentID;
    NSString *myPassword;
    
    NSString *userName;
    
    NSMutableArray *courseResultAry;
}

@synthesize courseKeyword, teacherKeyword;

- (void)viewDidLoad {
    [super viewDidLoad];
    courseResultAry = [[NSMutableArray alloc] init];
    
    [self retreiveAccountDataFromFile];
    
    if ([self checkInternet]) {
        [self retreiveCourses];
    }
    else
    {
        [self showErrorWithErrorCode:404];
    }


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)retreiveCourses
{
    NSString *post = [NSString stringWithFormat:@"Key-Name=%@&Key-Teacher=%@", courseKeyword, teacherKeyword];
    
    NSString *URL = @"https://luthertsai.com/ntut_criticize_sys/SearchCourses.php";
    NSURL *url = [NSURL URLWithString:URL];
    client = [[HttpPost alloc] initWithURL:url postData:post cookie:nil timeout:5 delegate:self];
    [client startDownloadWithURL:url postData:post cookie:nil];
    currentHTTPIndex = 0;
}

#pragma mark - HTTP Post Delegate

- (void) httpPost:(HttpPost *)httpPost didReceiveResponseWithCookie:(NSString *)responseCookie
{
    
}

- (void) httpPost:(HttpPost *)httpPost didFinishWithData:(NSData *)fileData
{
    switch (currentHTTPIndex) {
        case 0:
        {
            NSError *errorJson=nil;
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:&errorJson];
            
            //NSLog(@"responseDict=%@",responseDict);
            
            courseResultAry = [[NSMutableArray alloc] init];
            if ([[responseDict objectForKey:@"IsFounded"] integerValue]) {
                courseResultAry = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"Courses"]];
            }
            else
            {
                [self showErrorWithErrorCode:300];
            }
            
        }
            break;
        default:
            break;
    }
    [searchResultTable reloadData];
}

- (void) httpPost:(HttpPost *)httpPost didFailWithError:(NSError *)error
{
    
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

#pragma mark - Error Function

- (void) showErrorWithErrorCode:(int)errCode
{
    switch (errCode) {
        case 404:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"請檢查網路設定"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 300:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統回報"
                                                              message:@"Oops...沒有搜尋結果，可能還沒有評論喔！！！\n請重新搜尋"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 9997:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"需要更新資料，請先至學分計算/課表查詢更新資料"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"確認", nil];
            caution.tag = 9999;
            [caution show];
        }
            break;

        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [courseResultAry count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseSearchResultCell" owner:self options:nil];
    UITableViewCell *cell = [nibs objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    courseName.text = [[courseResultAry objectAtIndex:indexPath.row] objectForKey:@"course_name"];
    courseTeacher.text = [[courseResultAry objectAtIndex:indexPath.row] objectForKey:@"teacher_name"];
    commentNum.text = [[courseResultAry objectAtIndex:indexPath.row] objectForKey:@"total_num"];
    
    if ([commentNum.text integerValue] != 0) {
        commentImg.image = [UIImage imageNamed:@"Comment-Blue"];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![userName isEqualToString:@""] && userName != nil) {
        [self performSegueWithIdentifier:@"showCourseDetailSegue"
                                  sender:[courseResultAry objectAtIndex:indexPath.row]];
    }
    else
    {
        [self showErrorWithErrorCode:9997];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showCourseDetailSegue"])
    {
        CourseDetailTableViewController *vc = [segue destinationViewController];
        [vc setValue:[sender objectForKey:@"course_code"] forKey:@"courseCode"];
        [vc setValue:[sender objectForKey:@"course_name"] forKey:@"courseName"];
        [vc setValue:[sender objectForKey:@"teacher_name"] forKey:@"teacherName"];
        [vc setValue:myStudentID forKey:@"studentID"];
        [vc setValue:userName forKey:@"studentName"];
        [vc setValue:@"Y" forKey:@"canCriticize"];
    }
}

#pragma mark - Save/Retrieve Function

- (void)retreiveAccountDataFromFile {
    //Get Text Input
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myAccount.plist"];
    
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
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
    filePath = [documentFolder stringByAppendingFormat:@"/UserName.plist"];
    
    //Check if the file exists
    fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        NSDictionary *accountDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        userName = [accountDict objectForKey:@"User-Name"];
    }
    else
    {
        userName = @"蔡易儒";
    }
    
}

@end
