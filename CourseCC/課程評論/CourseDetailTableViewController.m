//
//  CourseDetailTableViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/9/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseDetailTableViewController.h"

@interface CourseDetailTableViewController ()
{
    HttpPost *client;
    
    NSString *courseDescription;
    
    NSString *positiveNum;
    NSString *nonPositiveNum;
    NSMutableArray *criticizeArray;
    
    BOOL isCriticize;
    BOOL isAbleToCriticize;
    int currentHTTPIndex;
}
@end

@implementation CourseDetailTableViewController
@synthesize courseName, courseCode, teacherName, studentID, studentName, canCriticize;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    client = [[HttpPost alloc] init];
    criticizeArray = [[NSMutableArray alloc] init];
    
    if ([canCriticize isEqualToString:@"Y"]) {
        isAbleToCriticize = YES;
    }
    else {
        isAbleToCriticize = NO;
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    if ([self checkInternet]) {
        [self retreiveCourseDescription];
        [self retreiveCourseCriticize];
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

#pragma mark - Network Handling

- (void)deleteCriticizeFromSever
{
    NSString *post = [NSString stringWithFormat:@"Course-Code=%@&Course-Teacher=%@&StudentID=%@",courseCode,teacherName,studentID];
    
    NSString *URL = @"http://140.124.182.99/criticize_sys/CriticizeDelete.php";
    NSURL *url = [NSURL URLWithString:URL];
    client = [[HttpPost alloc] initWithURL:url postData:post cookie:nil timeout:5 delegate:self];
    currentHTTPIndex = 2;
    [client startDownloadWithURL:url postData:post cookie:nil];
}

- (void)postCriticizeToSeverWithContent:(NSString *)content Recommend:(BOOL)isRecommend
{
    NSString *recommendedContent = @"";
    if (isRecommend) {
        recommendedContent = @"Y";
    }
    else {
        recommendedContent = @"N";
    }
    
    NSString *post = [NSString stringWithFormat:@"Course-Code=%@&Course-Teacher=%@&Criticize-Content=%@&Recommend=%@&StudentID=%@&StudentName=%@",courseCode,teacherName,content,recommendedContent,studentID,studentName];
    
    NSString *URL = @"https://luthertsai.com/ntut_criticize_sys/CriticalSystem.php";
    NSURL *url = [NSURL URLWithString:URL];
    client = [[HttpPost alloc] initWithURL:url postData:post cookie:nil timeout:5 delegate:self];
    currentHTTPIndex = 1;
    [client startDownloadWithURL:url postData:post cookie:nil];
}

- (void)retreiveCourseCriticize
{
    NSString *post = [NSString stringWithFormat:@"Course-Name=%@&Course-Code=%@&Course-Teacher=%@&StudentID=%@",courseName,courseCode, teacherName, studentID];
    
    NSString *URL = @"https://luthertsai.com/ntut_criticize_sys/CriticizeRetreive.php";
    NSURL *url = [NSURL URLWithString:URL];
    client = [[HttpPost alloc] initWithURL:url postData:post cookie:nil timeout:5 delegate:self];
    [client startDownloadWithURL:url postData:post cookie:nil];
    currentHTTPIndex = 0;
}

- (void)retreiveCourseDescription
{
    NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://aps.ntut.edu.tw/course/tw/Curr.jsp?format=-2&code=%@", courseCode]];
    NSString *webData= [NSString stringWithContentsOfURL:url
                                                encoding:strEncode
                                                   error:nil];
    
    
    webData = [webData stringByReplacingOccurrencesOfString:@" " withString:@""];
    webData = [webData stringByReplacingOccurrencesOfString:@"　" withString:@""];
    webData = [webData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    webData = [webData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    
    NSString *szNeedle= @"ChineseDescription<tdcolspan=4>";
    NSRange range = [webData rangeOfString:szNeedle];
    NSInteger startIdx = range.location + range.length;
    szNeedle= @"<tr><th><fontcolor=#d00000>英文概述";
    range = [webData rangeOfString:szNeedle];
    NSInteger endIdx = range.location;
    webData = [[webData substringToIndex:endIdx] substringFromIndex:startIdx];
    
    courseDescription = webData;
}

#pragma mark - IBAction Function

- (IBAction)touchActionButton:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet;
    NSString *selectionTitle = @"";
    if (isCriticize) {
        selectionTitle = @"修改評論";
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"評論選項"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:@"刪除評論"
                                         otherButtonTitles:selectionTitle, nil];
        actionSheet.tag = 100;
    }
    else {
        selectionTitle = @"評論課程";
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"評論選項"
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:selectionTitle, nil];
        actionSheet.tag = 200;
    }
    
    [actionSheet showInView:self.view];
    
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
            
            positiveNum = [responseDict objectForKey:@"GOOD-NUM"];
            nonPositiveNum = [responseDict objectForKey:@"BAD-NUM"];
            int isCriticizeValue = (int)[[responseDict objectForKey:@"IsCriticize"] integerValue];
            if (isCriticizeValue == 0) {
                isCriticize = NO;
            }
            else {
                isCriticize = YES;
            }
            
            if ([[responseDict objectForKey:@"TOTAL-NUM"] integerValue]) {
                criticizeArray = [[NSMutableArray alloc] initWithArray:[responseDict objectForKey:@"CriticizeContents"] copyItems:YES];
            }
            
            [CourseDetailTableView reloadData];
        }
            break;
        case 1:
        {
            [self retreiveCourseCriticize];
            [self showErrorWithErrorCode:200];
        }
            break;
        case 2:
        {
            [self retreiveCourseCriticize];
            [self showErrorWithErrorCode:201];
        }
            break;
        default:
            break;
    }
}

- (void) httpPost:(HttpPost *)httpPost didFailWithError:(NSError *)error
{
    
}

#pragma mark - Action Sheet Delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
            {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"確認是否刪除評論？"
                                                                         delegate:self
                                                                cancelButtonTitle:@"取消"
                                                           destructiveButtonTitle:@"確認刪除"
                                                                otherButtonTitles:nil];
                actionSheet.tag = 999;
                [actionSheet showInView:self.view];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == 200)
    {
        switch (buttonIndex) {
            case 0:
            {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"評論課程" message:@"給這門課一些評語吧" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"👍🏻這門課給推", @"👎🏻這門課不推", nil];
                alertView.alertViewStyle=UIAlertViewStylePlainTextInput;
                alertView.tag = actionSheet.tag;
                [alertView show];
            }
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == 999)
    {
        switch (buttonIndex) {
            case 0:
            {
                [self deleteCriticizeFromSever];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
        {
            switch (buttonIndex) {
                case 0:
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 200:
        {
            UITextField *criticizeInput = [alertView textFieldAtIndex:0];
            //NSLog(@"%@", criticizeInput.text);
            switch (buttonIndex) {
                case 1:
                {
                    [self postCriticizeToSeverWithContent:criticizeInput.text Recommend:YES];
                }
                    break;
                case 2:
                {
                    [self postCriticizeToSeverWithContent:criticizeInput.text Recommend:NO];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewHeader" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    
    switch (section) {
        case 0:
        {
            HeaderTitle.text = @"課程詳細資訊";
            LikeImage.hidden = YES;
            DislikeImage.hidden = YES;
            LikeNumber.hidden = YES;
            DislikeNumber.hidden = YES;
        }
            break;
        case 1:
        {
            HeaderTitle.text = @"課程評論";
            LikeNumber.text = positiveNum;
            DislikeNumber.text = nonPositiveNum;
        }
            break;
        default:
            break;
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewHeader" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    return view.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRow = 0;
    switch (section) {
        case 0:
            numberOfRow = 4;
            break;
        case 1:
            numberOfRow = (int)[criticizeArray count];
            break;
        default:
            break;
    }
    return numberOfRow;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    cell = [nibs objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    CourseDetailLabel.text = @"課程編號：";
                    CourseDetailContent.text = courseCode;
                }
                    break;
                case 1:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    cell = [nibs objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    CourseDetailLabel.text = @"課程名稱：";
                    CourseDetailContent.text = courseName;
                }
                    break;
                case 2:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    cell = [nibs objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    CourseDetailLabel.text = @"課程教師：";
                    CourseDetailContent.text = teacherName;
                }
                    break;
                case 3:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDescriptionTableViewCell" owner:self options:nil];
                    cell = [nibs objectAtIndex:0];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    CourseDescription.text = courseDescription;
                }
                    break;
                default:
                {
                }
                    break;
            }
        }
            break;
        case 1:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseCriticizeTableViewCell" owner:self options:nil];
            cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSDictionary *criticizeContent = [criticizeArray objectAtIndex:indexPath.row];
            if ([[criticizeContent objectForKey:@"recommend"]integerValue]) {
                CriticizeType.image = [UIImage imageNamed:@"Like"];
            }
            else {
                CriticizeType.image = [UIImage imageNamed:@"Dislike"];
            }
            CourseCriticize.text = [criticizeContent objectForKey:@"content"];
            CourseCriticizeUser.text = [NSString stringWithFormat:@"%@同學", [[criticizeContent objectForKey:@"student_name"] substringToIndex:1]];
        }
            break;
        default:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
            cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
    }
    
    //Change Cell Color
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowHeight = 0;
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    UITableViewCell *cell = [nibs objectAtIndex:0];
                    rowHeight = cell.frame.size.height;
                }
                    break;
                case 1:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    UITableViewCell *cell = [nibs objectAtIndex:0];
                    rowHeight = cell.frame.size.height;
                }
                    break;
                case 2:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
                    UITableViewCell *cell = [nibs objectAtIndex:0];
                    rowHeight = cell.frame.size.height;
                }
                    break;
                case 3:
                {
                    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDescriptionTableViewCell" owner:self options:nil];
                    UITableViewCell *cell = [nibs objectAtIndex:0];
                    rowHeight = cell.frame.size.height;
                }
                    break;
                default:
                {
                }
                    break;
            }
        }
            break;
        case 1:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseCriticizeTableViewCell" owner:self options:nil];
            UITableViewCell *cell = [nibs objectAtIndex:0];
            rowHeight = cell.frame.size.height;
        }
            break;
        default:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CourseDetailTableViewCell" owner:self options:nil];
            UITableViewCell *cell = [nibs objectAtIndex:0];
            rowHeight = cell.frame.size.height;
        }
            break;
    }
    return rowHeight;
}

#pragma mark - Fetching Check

- (BOOL)checkInternet
{
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://luthertsai.com/"] encoding:NSUTF8StringEncoding error:nil];
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
        case 200:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統訊息"
                                                              message:@"成功送出評論"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 201:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統訊息"
                                                              message:@"成功刪除評論"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
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
        default:
            break;
    }
}

@end
