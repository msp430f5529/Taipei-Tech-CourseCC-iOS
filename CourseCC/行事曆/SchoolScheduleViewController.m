//
//  SchoolScheduleViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2016/5/3.
//  Copyright (c) 2016年 Luther Tsai. All rights reserved.
//

#import "SchoolScheduleViewController.h"
#import "SWRevealViewController.h"
#import "HttpPost.h"
#import "SchoolScheduleModel.h"
#import "ScheduleDataAbstractor.h"

@interface SchoolScheduleViewController ()
{
    HttpPost *client;
}

@end

@implementation SchoolScheduleViewController

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
    
    //Get Current Month
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    currentMonth = (int)[components month];
    currentMonthLabel.text = [self labelStringOfMonth:currentMonth];
    [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth - 1)] forState:UIControlStateNormal];
    [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth + 1)] forState:UIControlStateNormal];
    
    if (currentMonth == 8) {
        previousMonthLabel.hidden = YES;
    }else{
        previousMonthLabel.hidden = NO;
    }
    
    if (currentMonth == 7) {
        nextMonthLabel.hidden = YES;
    }else{
        nextMonthLabel.hidden = NO;
    }
    
    [self retreiveScheduleDataFromFile];
    [scheduleTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) activityIndicatorSwitch:(BOOL)isActive
{
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

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

}

#pragma mark - TableView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%ld", (long)indexPath.row);
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"SchoolScheduleTableViewCell" owner:self options:nil];
    UITableViewCell *cell = [nibs objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (scheduleArray != NULL) {
        NSString *eventString = [[scheduleArray objectAtIndex:indexPath.row] objectForKey:@"Event-Detail"];
        EventOfNTUT.text = eventString;
        NSString *IsVacation = @"放假一天";
        NSRange searchRange = [eventString rangeOfString:IsVacation];
        if (searchRange.location != NSNotFound) {
            EventOfNTUT.textColor = [UIColor redColor];
        }
        IsVacation = @"放假";
        searchRange = [eventString rangeOfString:IsVacation];
        if (searchRange.location != NSNotFound) {
            EventOfNTUT.textColor = [UIColor redColor];
        }
        IsVacation = @"補假";
        searchRange = [eventString rangeOfString:IsVacation];
        if (searchRange.location != NSNotFound) {
            EventOfNTUT.textColor = [UIColor redColor];
        }
        Date.text = [[scheduleArray objectAtIndex:indexPath.row] objectForKey:@"Event-Day"];
        Weekday.text = [self determineTheWeekDayWithYear:[[scheduleArray objectAtIndex:indexPath.row] objectForKey:@"Event-Year"] Month:[NSString stringWithFormat:@"%d", currentMonth] Day:Date.text];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (scheduleArray != NULL) {
        return [scheduleArray count];
    }else{
        return 0;
    }
}

#pragma mark - Algorithm

- (NSString *)determineTheWeekDayWithYear:(NSString*)yyyy Month:(NSString*)mm Day:(NSString *)dd
{
    int CodeOfMonth = 0;
    switch ([mm intValue]) {
        case 1:
            CodeOfMonth = 5;
            break;
        case 2:
            CodeOfMonth = 1;
            break;
        case 3:
            CodeOfMonth = 1;
            break;
        case 4:
            CodeOfMonth = 4;
            break;
        case 5:
            CodeOfMonth = 6;
            break;
        case 6:
            CodeOfMonth = 2;
            break;
        case 7:
            CodeOfMonth = 4;
            break;
        case 8:
            CodeOfMonth = 0;
            break;
        case 9:
            CodeOfMonth = 3;
            break;
        case 10:
            CodeOfMonth = 5;
            break;
        case 11:
            CodeOfMonth = 1;
            break;
        case 12:
            CodeOfMonth = 3;
            break;
        default:
            break;
    }
    
    int CodeOfLeapYear = 0;
    if ((([yyyy intValue] - 2000) % 4) == 0) {
        if ([mm intValue] >= 3) {
            CodeOfLeapYear = ([yyyy intValue] - 2000) / 4 + 1;
        }else if([mm intValue] == 2){
            if ([dd intValue] == 29) {
                CodeOfLeapYear = ([yyyy intValue] - 2000) / 4 + 1;
            }else{
                CodeOfLeapYear = ([yyyy intValue] - 2000) / 4 + 1;
            }
        }else{
            CodeOfLeapYear = ([yyyy intValue] - 2000) / 4;
        }
    }else{
        CodeOfLeapYear = ([yyyy intValue] - 2000) / 4 + 1;
    }
    
    int remain = (([yyyy intValue] - 2000) + CodeOfLeapYear + CodeOfMonth + [dd intValue]) % 7;
    
    switch (remain) {
        case 0:
            return @"日";
            break;
        case 1:
            return @"一";
            break;
        case 2:
            return @"二";
            break;
        case 3:
            return @"三";
            break;
        case 4:
            return @"四";
            break;
        case 5:
            return @"五";
            break;
        case 6:
            return @"六";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)btnStringOfMonth:(int)month
{
    switch (month) {
        case 1:
            return @"Jan.";
            break;
        case 2:
            return @"Feb.";
            break;
        case 3:
            return @"Mar.";
            break;
        case 4:
            return @"Apr.";
            break;
        case 5:
            return @"May.";
            break;
        case 6:
            return @"Jun.";
            break;
        case 7:
            return @"Jul.";
            break;
        case 8:
            return @"Aug.";
            break;
        case 9:
            return @"Sep.";
            break;
        case 10:
            return @"Oct.";
            break;
        case 11:
            return @"Nov.";
            break;
        case 12:
            return @"Dec.";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)labelStringOfMonth:(int)month
{
    switch (month) {
        case 1:
            return @"2016 January";
            break;
        case 2:
            return @"2016 February";
            break;
        case 3:
            return @"2016 March";
            break;
        case 4:
            return @"2016 April";
            break;
        case 5:
            return @"2016 May";
            break;
        case 6:
            return @"2016 June";
            break;
        case 7:
            return @"2016 July";
            break;
        case 8:
            return @"2015 August";
            break;
        case 9:
            return @"2015 September";
            break;
        case 10:
            return @"2015 October";
            break;
        case 11:
            return @"2015 November";
            break;
        case 12:
            return @"2015 December";
            break;
        default:
            return @"";
            break;
    }
}

- (int)currentMonthOnViewWithTitle:(NSString *)title
{
    int Month = 1;
    NSString *currentTitle = [title substringFromIndex:5];
    //NSLog(@"currentTitle: %@", currentTitle);
    if ([currentTitle isEqualToString:@"January"]){
        Month = 1;
    }else if ([currentTitle isEqualToString:@"February"]){
        Month = 2;
    }else if ([currentTitle isEqualToString:@"March"]){
        Month = 3;
    }else if ([currentTitle isEqualToString:@"April"]){
        Month = 4;
    }else if ([currentTitle isEqualToString:@"May"]){
        Month = 5;
    }else if ([currentTitle isEqualToString:@"June"]){
        Month = 6;
    }else if ([currentTitle isEqualToString:@"July"]){
        Month = 7;
    }else if ([currentTitle isEqualToString:@"August"]){
        Month = 8;
    }else if ([currentTitle isEqualToString:@"September"]){
        Month = 9;
    }else if ([currentTitle isEqualToString:@"October"]){
        Month = 10;
    }else if ([currentTitle isEqualToString:@"November"]){
        Month = 11;
    }else if ([currentTitle isEqualToString:@"December"]){
        Month = 12;
    }
    
    return Month;
}

#pragma mark - Touch Function

- (IBAction)touchPreviousBtn:(UIButton *)sender {
    if (currentMonth > 8) {
        if ((currentMonth - 1) == 8) {
            previousMonthLabel.hidden = YES;
        }else{
            previousMonthLabel.hidden = NO;
        }
        [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth - 1 - 1)] forState:UIControlStateNormal];
        [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth - 1 + 1)] forState:UIControlStateNormal];
        currentMonthLabel.text = [self labelStringOfMonth:(currentMonth - 1)];
        currentMonth--;
    }else{
        previousMonthLabel.hidden = NO;
        nextMonthLabel.hidden = NO;
        if ((currentMonth - 1) == 0){
            [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth)] forState:UIControlStateNormal];
            currentMonth = 12;
            [previousMonthLabel setTitle:[self btnStringOfMonth:currentMonth - 1] forState:UIControlStateNormal];
            currentMonthLabel.text = [self labelStringOfMonth:(currentMonth)];
        }else{
            if ((currentMonth - 1) == 1)
            {
                [previousMonthLabel setTitle:[self btnStringOfMonth:12] forState:UIControlStateNormal];
            }else{
                [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth - 1 - 1)] forState:UIControlStateNormal];
            }
            [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth - 1 + 1)] forState:UIControlStateNormal];
            currentMonthLabel.text = [self labelStringOfMonth:(currentMonth - 1)];
            currentMonth--;
        }
    }
    [self retreiveScheduleDataFromFile];
    [scheduleTableView reloadData];
}

- (IBAction)touchForwardBtn:(UIButton *)sender {
    if (currentMonth >= 8) {
        previousMonthLabel.hidden = NO;
        nextMonthLabel.hidden = NO;
        if ((currentMonth + 1) == 13) {
            [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth)] forState:UIControlStateNormal];
            [nextMonthLabel setTitle:[self btnStringOfMonth:2] forState:UIControlStateNormal];
            currentMonthLabel.text = [self labelStringOfMonth:1];
            currentMonth = 1;
        }else{
            [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth + 1 - 1)] forState:UIControlStateNormal];
            if ((currentMonth + 1 + 1) == 13) {
                [nextMonthLabel setTitle:[self btnStringOfMonth:1] forState:UIControlStateNormal];
            }else{
                [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth + 1 + 1)] forState:UIControlStateNormal];
            }
            currentMonthLabel.text = [self labelStringOfMonth:(currentMonth + 1)];
            currentMonth++;
        }
    }else{
        if ((currentMonth + 1) == 7) {
            nextMonthLabel.hidden = YES;
        }else{
            nextMonthLabel.hidden = NO;
        }
        [previousMonthLabel setTitle:[self btnStringOfMonth:(currentMonth + 1 - 1)] forState:UIControlStateNormal];
        [nextMonthLabel setTitle:[self btnStringOfMonth:(currentMonth + 1 + 1)] forState:UIControlStateNormal];
        currentMonthLabel.text = [self labelStringOfMonth:(currentMonth + 1)];
        currentMonth++;
    }
    [self retreiveScheduleDataFromFile];
    [scheduleTableView reloadData];
}

- (IBAction)touchRefreshBtn:(UIBarButtonItem *)sender {
    
    [self activityIndicatorSwitch:YES];
    
    if ([self checkInternet]) {
        NSString *calendarURL = @"http://www.cc.ntut.edu.tw/~wwwoaa/oaa-nwww/oaa-cal/oaa-cal_099.html";
        NSURL *url = [NSURL URLWithString:calendarURL];
        
        client = [[HttpPost alloc] initWithURL:url postData:@"" cookie:@"" timeout:5 delegate:self];
        [client startDownloadWithURL:url postData:@"" cookie:@""];
    }
    else
    {
        UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                          message:@"請檢查網路設定"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [caution show];
        [self activityIndicatorSwitch:NO];
    }
}

#pragma mark - Save/Retrieve Function

- (void)retreiveScheduleDataFromFile {
    ScheduleDataAbstractor *dataAbstractor = [[ScheduleDataAbstractor alloc] init];
    
    scheduleArray = [[NSArray alloc] initWithArray:[dataAbstractor scheduleOfMonth:currentMonth] copyItems:YES];
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

#pragma mark - HTTP Post Delegate

- (void) httpPost:(HttpPost *)httpPost didFinishWithData:(NSData *)fileData
{
    NSString *dataStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    SchoolScheduleModel *model = [[SchoolScheduleModel alloc] init];
    [model saveDataToModelWithString:dataStr];
    [self retreiveScheduleDataFromFile];
    [scheduleTableView reloadData];
    [self activityIndicatorSwitch:NO];
}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
