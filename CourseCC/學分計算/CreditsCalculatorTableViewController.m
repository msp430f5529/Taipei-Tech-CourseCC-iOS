//
//  CreditsCalculatorTableViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/2.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CreditsCalculatorTableViewController.h"
#import "SWRevealViewController.h"
#import "HttpPost.h"
#import "OCRNportal.h"
#import "LAECourseDataAbstractor.h"
#import "CourseCreditsModel.h"
#import "QueryScoreDataAbstractor.h"
#import "GraduationStandardAbstractor.h"
#import "CourseDetailTableViewController.h"
#import "CourseDataModel.h"

#define ORIGIN_X 0
#define ORIGIN_Y 0
#define SCREEN_W [[UIScreen mainScreen] bounds].size.width
#define SCREEN_H [[UIScreen mainScreen] bounds].size.height - 64
#define PRESECTION 3

@interface CreditsCalculatorTableViewController ()
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
    BOOL isRefreshData;
    BOOL isSAIP;
    
    NSArray *LAECourses;
    NSArray *myCourses;
    NSArray *graduationStandard;
    NSMutableArray *sectionControl;
    NSMutableArray *SAIPGroup;
    NSArray *myCoursesOnTable;
    
    int mustGetCreditsOfCollege;
    int mustGetCreditsofSchool;
    int selectedCredits;
    int mustGetCreditsOfCollege_pro;
    int museGetCreditsofSchool_pro;
    int selectedCredits_pro;
    int numOfSemesterWithData;
    int SemesterOffset;
    int terminatedFlag;
    int currentSAIPGroup;
    
    int errLoginCount;
    
    UILabel *coverLabel;
    UIActivityIndicatorView *ActivityIndicator;
}

@end

@implementation CreditsCalculatorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isInProcess = NO;
    isRefreshData = NO;
    
    //Sidebar Controller
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self->sidebarButton setTarget: self.revealViewController];
        [self->sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    mustGetCreditsOfCollege = 0;
    mustGetCreditsofSchool = 0;
    selectedCredits = 0;
    mustGetCreditsOfCollege_pro = 0;
    museGetCreditsofSchool_pro = 0;
    selectedCredits_pro = 0;
    numOfSemesterWithData = 0;
    
    [self retreiveAccountDataFromFile];
    [self loadDataFromFile];
    
    [courseTable reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveAccountDataToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self saveAccountDataToFile];
}

- (void)loadDataFromFile
{
    numOfSemesterWithData = 0;
    CourseCreditsModel *model = [[CourseCreditsModel alloc] init];
    LAECourses = [[NSArray alloc] initWithArray:[model readMyLAECourseCredits] copyItems:YES];
    myCourses = [[NSArray alloc] initWithArray:[model readMyCourseAndScore] copyItems:YES];
    graduationStandard = [[NSArray alloc] initWithArray:[model readGraduationStandard] copyItems:YES];
    
    sectionControl = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in myCourses) {
        if ([[dict objectForKey:@"NO-DATA"] isEqualToString:@"NO"]) {
            if (isRefreshData) {
                for (NSDictionary *courseData in [dict objectForKey:@"Semester-Courses"]) {
                    if ([[courseData objectForKey:@"Course-Type"] isEqualToString:@"選"]) {
                        [courseData setValue:@"6" forKey:@"CourseType-Tag"];
                    }
                    else if ([[courseData objectForKey:@"Course-Type"] isEqualToString:@"通"])
                    {
                        [courseData setValue:@"2" forKey:@"CourseType-Tag"];
                    }
                    else if ([[courseData objectForKey:@"Course-Type"] isEqualToString:@"必"])
                    {
                        [courseData setValue:@"2" forKey:@"CourseType-Tag"];
                    }
                    else
                    {
                        [courseData setValue:@"7" forKey:@"CourseType-Tag"];
                    }
                }
                
            }
            numOfSemesterWithData++;
        }
    }
    
    SemesterOffset = (int)[myCourses count] - numOfSemesterWithData;
    
    for (int i = 0; i < numOfSemesterWithData + PRESECTION; i++) {
        [sectionControl addObject:@"1"];
    }
    //NSLog(@"%@", myCourses);
    
    SAIPGroup = [[NSMutableArray alloc] init];
    
    NSString *myDepartmentCode = @"";
    if ([myStudentID length] == 9) {
        myDepartmentCode = [[myStudentID substringFromIndex:3] substringToIndex:3];
    }
    else if ([myStudentID length] == 8){
        myDepartmentCode = [[myStudentID substringFromIndex:2] substringToIndex:3];
    }
    
    if ([myDepartmentCode integerValue] == 810 || [myDepartmentCode integerValue] == 820 || [myDepartmentCode integerValue] == 830 || [myDepartmentCode integerValue] == 840) {
        isSAIP = YES;
        currentSAIPGroup = 0;
        if (graduationStandard != nil) {
            for (NSDictionary *dict in graduationStandard) {
                if ([[[dict objectForKey:@"DEP-CODE"] substringToIndex:2] isEqualToString:[myDepartmentCode substringToIndex:2]]) {
                    [SAIPGroup addObject:dict];
                }
            }
        }
    }else{
        isSAIP = NO;
    }
    
}

#pragma mark - Table view data source

- (void)countCredits
{
    mustGetCreditsOfCollege = 0;
    mustGetCreditsofSchool = 0;
    selectedCredits = 0;
    mustGetCreditsOfCollege_pro = 0;
    museGetCreditsofSchool_pro = 0;
    selectedCredits_pro = 0;
    
    for (NSDictionary *courses in myCourses) {
        if ([[courses objectForKey:@"NO-DATA"] isEqualToString:@"NO"])
        {
            NSArray *coursesArray = [[NSArray alloc] initWithArray:[courses objectForKey:@"Semester-Courses"] copyItems:YES];
            for (NSDictionary *dict in coursesArray) {
                if ([dict objectForKey:@"CourseType-Tag"] != nil && [[dict objectForKey:@"Course-Score"] integerValue] >= 60) {
                    
                    switch ([[dict objectForKey:@"CourseType-Tag"] integerValue]) {
                        case 1:
                            mustGetCreditsOfCollege += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        case 2:
                            mustGetCreditsofSchool += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        case 3:
                            selectedCredits += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        case 4:
                            mustGetCreditsOfCollege_pro += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        case 5:
                            museGetCreditsofSchool_pro += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        case 6:
                            selectedCredits_pro += [[dict objectForKey:@"Course-Credits"] integerValue];
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return numOfSemesterWithData + PRESECTION;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomSectionHeaderView" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    
    [HeaderButton addTarget:self action:@selector(touchHeaderBtn:) forControlEvents:UIControlEventTouchUpInside];
    HeaderButton.tag = section;
    
    switch (section) {
        case 0:
        {
            HeaderTitleLabel.text = @"畢業標準";
            
            HeaderInfoLabel.text = [NSString stringWithFormat:@""];
        }
            break;
        case 1:
        {
            HeaderTitleLabel.text = @"學分總覽";
            
            int actualCredits = mustGetCreditsOfCollege + mustGetCreditsofSchool + selectedCredits + mustGetCreditsOfCollege_pro + museGetCreditsofSchool_pro + selectedCredits_pro;
            
            HeaderInfoLabel.text = [NSString stringWithFormat:@"實得學分( %d )", actualCredits];
        }
            break;
        case 2:
        {
            HeaderTitleLabel.text = @"博雅總覽";
            int coreCredits = 0;
            int additionalCredits = 0;
            for (int i = 0; i < [LAECourses count]; i++) {
                coreCredits += [[[LAECourses objectAtIndex:i] objectForKey:@"Actual-Credits"] integerValue];
                additionalCredits +=[[[LAECourses objectAtIndex:i] objectForKey:@"Addition-Credits"] integerValue];
            }
            HeaderInfoLabel.text = [NSString stringWithFormat:@"實得核心( %d ) 實得選修( %d )", coreCredits, additionalCredits];
        }
            break;
        default:
        {
            HeaderTitleLabel.text = [[myCourses objectAtIndex:section - PRESECTION + SemesterOffset] objectForKey:@"Semester-Title"];
            if ([[sectionControl objectAtIndex:section] integerValue] == 1) {
                if ([[[myCourses objectAtIndex:(section - PRESECTION)] objectForKey:@"NO-DATA"] isEqualToString:@"NO"]) {
                    HeaderInfoLabel.text = @"▲";
                }
                else
                {
                    HeaderInfoLabel.text = @"";
                }
            }
            else {
                HeaderInfoLabel.text = @"▼";
            }
        }
            break;
    }
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomSectionHeaderView" owner:self options:nil];
    UIView *view = [nibs objectAtIndex:0];
    return view.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (isSAIP) {
                switch (indexPath.row) {
                    case 0:
                    {
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"DepartmentSelectionCell" owner:self options:nil];
                        UITableViewCell *cell = [nibs objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        NSString *myDepartmentCode = @"";
                        if ([myStudentID length] == 9) {
                            myDepartmentCode = [[myStudentID substringFromIndex:3] substringToIndex:3];
                        }
                        else if ([myStudentID length] == 8){
                            myDepartmentCode = [[myStudentID substringFromIndex:2] substringToIndex:3];
                        }
                        
                        switch ([myDepartmentCode integerValue]) {
                            case 810:
                            {
                                departmentLabel.text = @"機電學士班";
                            }
                                break;
                            case 820:
                            {
                                departmentLabel.text = @"電資學士班";
                            }
                                break;
                            case 830:
                            {
                                departmentLabel.text = @"工程科技學士班";
                            }
                                break;
                            case 840:
                            {
                                departmentLabel.text = @"創意設計學士班";
                            }
                                break;
                            default:
                            {
                                NSMutableDictionary *myDepartmentDict = [[NSMutableDictionary alloc] init];
                                for (NSDictionary *dict in graduationStandard) {
                                    if ([[dict objectForKey:@"DEP-CODE"] isEqualToString:myDepartmentCode]) {
                                        myDepartmentDict = [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:YES];
                                        break;
                                    }
                                }
                                departmentLabel.text = [myDepartmentDict objectForKey:@"DEP-NAME"];
                            }
                                break;
                        }
                        departmentSelectionBtn.hidden = YES;
                        return cell;
                    }
                        break;
                    case 1:
                    {
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"DepartmentSelectionCell" owner:self options:nil];
                        UITableViewCell *cell = [nibs objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        departmentTitle.text = @"組別：";
                        if ([SAIPGroup count] != 0) {
                            departmentLabel.text = [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-NAME"];
                        }
                        else
                        {
                            departmentLabel.text = @"請先更新資料";
                        }
                        return cell;
                    }
                        break;
                    default:
                    {
                        [self countCredits];
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"GraduationProgress" owner:self options:nil];
                        UITableViewCell *cell = [nibs objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        float percentageOfGraduation = 1.00f;
                        
                        int actualCredits = mustGetCreditsOfCollege + mustGetCreditsofSchool + selectedCredits + mustGetCreditsOfCollege_pro + museGetCreditsofSchool_pro + selectedCredits_pro;
                        if ([SAIPGroup count] != 0) {
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-REQ"]integerValue] != 0) {
                                float dep_req_p = (float)mustGetCreditsOfCollege / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-REQ"]integerValue];
                                if (dep_req_p < percentageOfGraduation && dep_req_p != 0) {
                                    percentageOfGraduation = dep_req_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-REQ"]integerValue] != 0) {
                                float sch_req_p = (float)mustGetCreditsofSchool / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-REQ"]integerValue];
                                if (sch_req_p < percentageOfGraduation && sch_req_p != 0) {
                                    percentageOfGraduation = sch_req_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-SEL"]integerValue] != 0) {
                                float dep_sel_p = (float)selectedCredits / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-SEL"]integerValue];
                                if (dep_sel_p < percentageOfGraduation && dep_sel_p != 0) {
                                    percentageOfGraduation = dep_sel_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-PRO"]integerValue] != 0) {
                                float dep_pro_p = (float)mustGetCreditsOfCollege_pro / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-PRO"]integerValue];
                                if (dep_pro_p < percentageOfGraduation && dep_pro_p != 0) {
                                    percentageOfGraduation = dep_pro_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-PRO"]integerValue] != 0) {
                                float sch_pro_p = (float)museGetCreditsofSchool_pro / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-PRO"]integerValue];
                                if (sch_pro_p < percentageOfGraduation && sch_pro_p != 0) {
                                    percentageOfGraduation = sch_pro_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"PRO-SEL"]integerValue] != 0) {
                                float pro_sel_p = (float)selectedCredits_pro / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"PRO-SEL"]integerValue];
                                if (pro_sel_p < percentageOfGraduation && pro_sel_p != 0) {
                                    percentageOfGraduation = pro_sel_p;
                                }
                            }
                            
                            if ([[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"TOTAL-CREDITS"]integerValue] != 0) {
                                float total_p = (float)actualCredits / [[[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"TOTAL-CREDITS"]integerValue];
                                if (total_p < percentageOfGraduation && total_p) {
                                    percentageOfGraduation = total_p;
                                }
                            }
                        }
                        
                        graduationDownloadValue.text = [NSString stringWithFormat:@"%d%%", (int)(percentageOfGraduation * 100)];
                        [graduationDownloadProgress setProgress:percentageOfGraduation];
                        return cell;
                    }
                        break;
                }
                
            }
            else{
                switch (indexPath.row) {
                    case 0:
                    {
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"DepartmentSelectionCell" owner:self options:nil];
                        UITableViewCell *cell = [nibs objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        NSString *myDepartmentCode = @"";
                        if ([myStudentID length] == 9) {
                            myDepartmentCode = [[myStudentID substringFromIndex:3] substringToIndex:3];
                        }
                        else if ([myStudentID length] == 8){
                            myDepartmentCode = [[myStudentID substringFromIndex:2] substringToIndex:3];
                        }
                        
                        NSMutableDictionary *myDepartmentDict = [[NSMutableDictionary alloc] init];
                        for (NSDictionary *dict in graduationStandard) {
                            if ([[dict objectForKey:@"DEP-CODE"] isEqualToString:myDepartmentCode]) {
                                myDepartmentDict = [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:YES];
                                break;
                            }
                        }
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            departmentLabel.text = [myDepartmentDict objectForKey:@"DEP-NAME"];
                        }
                        else
                        {
                            departmentLabel.text = @"請先更新資料";
                        }
                        departmentSelectionBtn.hidden = YES;
                        return cell;
                    }
                        break;
                    default:
                    {
                        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"GraduationProgress" owner:self options:nil];
                        UITableViewCell *cell = [nibs objectAtIndex:0];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        float percentageOfGraduation = 1.00f;
                        [self countCredits];
                        
                        NSString *myDepartmentCode = @"";
                        if ([myStudentID length] == 9) {
                            myDepartmentCode = [[myStudentID substringFromIndex:3] substringToIndex:3];
                        }
                        else if ([myStudentID length] == 8){
                            myDepartmentCode = [[myStudentID substringFromIndex:2] substringToIndex:3];
                        }
                        
                        NSMutableDictionary *myDepartmentDict = [[NSMutableDictionary alloc] init];
                        for (NSDictionary *dict in graduationStandard) {
                            if ([[dict objectForKey:@"DEP-CODE"] isEqualToString:myDepartmentCode]) {
                                myDepartmentDict = [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:YES];
                                break;
                            }
                        }
                        
                        int actualCredits = mustGetCreditsOfCollege + mustGetCreditsofSchool + selectedCredits + mustGetCreditsOfCollege_pro + museGetCreditsofSchool_pro + selectedCredits_pro;
                        
                        if ([[myDepartmentDict objectForKey:@"DEP-REQ"]integerValue] != 0) {
                            float dep_req_p = (float)mustGetCreditsOfCollege / [[myDepartmentDict objectForKey:@"DEP-REQ"]integerValue];
                            if (dep_req_p < percentageOfGraduation && dep_req_p != 0) {
                                percentageOfGraduation = dep_req_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"SCH-REQ"]integerValue] != 0) {
                            float sch_req_p = (float)mustGetCreditsofSchool / [[myDepartmentDict objectForKey:@"SCH-REQ"]integerValue];
                            if (sch_req_p < percentageOfGraduation && sch_req_p != 0) {
                                percentageOfGraduation = sch_req_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"SCH-SEL"]integerValue] != 0) {
                            float dep_sel_p = (float)selectedCredits / [[myDepartmentDict objectForKey:@"SCH-SEL"]integerValue];
                            if (dep_sel_p < percentageOfGraduation && dep_sel_p != 0) {
                                percentageOfGraduation = dep_sel_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"DEP-PRO"]integerValue] != 0) {
                            float dep_pro_p = (float)mustGetCreditsOfCollege_pro / [[myDepartmentDict objectForKey:@"DEP-PRO"]integerValue];
                            if (dep_pro_p < percentageOfGraduation && dep_pro_p != 0) {
                                percentageOfGraduation = dep_pro_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"SCH-PRO"]integerValue] != 0) {
                            float sch_pro_p = (float)museGetCreditsofSchool_pro / [[myDepartmentDict objectForKey:@"SCH-PRO"]integerValue];
                            if (sch_pro_p < percentageOfGraduation && sch_pro_p != 0) {
                                percentageOfGraduation = sch_pro_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"PRO-SEL"]integerValue] != 0) {
                            float pro_sel_p = (float)selectedCredits_pro / [[myDepartmentDict objectForKey:@"PRO-SEL"]integerValue];
                            if (pro_sel_p < percentageOfGraduation && pro_sel_p != 0) {
                                percentageOfGraduation = pro_sel_p;
                            }
                        }
                        
                        if ([[myDepartmentDict objectForKey:@"TOTAL-CREDITS"]integerValue] != 0) {
                            float total_p = (float)actualCredits / [[myDepartmentDict objectForKey:@"TOTAL-CREDITS"]integerValue];
                            if (total_p < percentageOfGraduation && total_p) {
                                percentageOfGraduation = total_p;
                            }
                        }
                        
                        return cell;
                    }
                        break;
                }
                
            }
        }
            break;
        case 1:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"AllCreditsTableViewCell" owner:self options:nil];
            UITableViewCell *cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [self countCredits];
            
            NSString *myDepartmentCode = @"";
            
            if ([myStudentID length] == 9) {
                myDepartmentCode = [[myStudentID substringFromIndex:3] substringToIndex:3];
            }
            else if ([myStudentID length] == 8){
                myDepartmentCode = [[myStudentID substringFromIndex:2] substringToIndex:3];
            }
            NSMutableDictionary *myDepartmentDict = [[NSMutableDictionary alloc] init];
            for (NSDictionary *dict in graduationStandard) {
                if ([[dict objectForKey:@"DEP-CODE"] isEqualToString:myDepartmentCode]) {
                    myDepartmentDict = [[NSMutableDictionary alloc] initWithDictionary:dict copyItems:YES];
                    break;
                }
            }
            
            
            switch (indexPath.row) {
                case 0:
                {
                    courseTypeTitleLabel.text = @"○ 部訂共同必修";
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsOfCollege, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-REQ"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsOfCollege];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsOfCollege, [myDepartmentDict objectForKey:@"DEP-REQ"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsOfCollege];
                        }
                        
                    }
                }
                    break;
                case 1:
                {
                    courseTypeTitleLabel.text = @"△ 校訂共同必修";
                    
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsofSchool, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-REQ"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsofSchool];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsofSchool, [myDepartmentDict objectForKey:@"SCH-REQ"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsofSchool];
                        }
                    }
                }
                    break;
                case 2:
                {
                    courseTypeTitleLabel.text = @"☆ 共同選修";
                    
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", selectedCredits, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-SEL"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", selectedCredits];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", selectedCredits, [myDepartmentDict objectForKey:@"SCH-SEL"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", selectedCredits];
                        }
                        
                    }
                }
                    break;
                case 3:
                {
                    courseTypeTitleLabel.text = @"● 部訂專業必修";
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsOfCollege_pro, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"DEP-PRO"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsOfCollege_pro];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", mustGetCreditsOfCollege_pro, [myDepartmentDict objectForKey:@"DEP-PRO"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", mustGetCreditsOfCollege_pro];
                        }
                        
                    }
                }
                    break;
                case 4:
                {
                    courseTypeTitleLabel.text = @"▲ 校訂專業必修";
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", museGetCreditsofSchool_pro, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"SCH-PRO"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", museGetCreditsofSchool_pro];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", museGetCreditsofSchool_pro, [myDepartmentDict objectForKey:@"SCH-PRO"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", museGetCreditsofSchool_pro];
                        }
                        
                    }
                }
                    break;
                case 5:
                {
                    courseTypeTitleLabel.text = @"★ 專業選修";
                    if (isSAIP) {
                        if ([SAIPGroup count] != 0) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", selectedCredits_pro, [[SAIPGroup objectAtIndex:currentSAIPGroup] objectForKey:@"PRO-SEL"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", selectedCredits_pro];
                        }
                    }
                    else
                    {
                        if ([myDepartmentDict objectForKey:@"DEP-NAME"]) {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d/%@ 學分", selectedCredits_pro, [myDepartmentDict objectForKey:@"PRO-SEL"]];
                        }
                        else
                        {
                            courseTypeCredits.text = [NSString stringWithFormat:@"%d 學分", selectedCredits_pro];
                        }
                        
                    }
                    
                }
                    break;
                default:
                    break;
            }
            return cell;
        }
            break;
        case 2:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"AllCreditsTableViewCell" owner:self options:nil];
            UITableViewCell *cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            courseTypeTitleLabel.text = [[LAECourses objectAtIndex:indexPath.row] objectForKey:@"Course-Aspect"];
            int coreCredits = 0;
            int additionalCredits = 0;
            
            if (![[[LAECourses objectAtIndex:indexPath.row] objectForKey:@"Actual-Credits"] isEqualToString:@""]) {
                coreCredits = (int)[[[LAECourses objectAtIndex:indexPath.row] objectForKey:@"Actual-Credits"] integerValue];
            }
            
            if (![[[LAECourses objectAtIndex:indexPath.row] objectForKey:@"Addition-Credits"] isEqualToString:@""]) {
                additionalCredits = (int)[[[LAECourses objectAtIndex:indexPath.row] objectForKey:@"Addition-Credits"] integerValue];
            }
            
            courseTypeCredits.text = [NSString stringWithFormat:@"核心：%d學分 選修：%d學分", coreCredits, additionalCredits];
            
            return cell;
        }
            break;
        default:
        {
            NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"CustomTableViewCell" owner:self options:nil];
            UITableViewCell *cell = [nibs objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if ([[[myCourses objectAtIndex:(indexPath.section - PRESECTION + SemesterOffset)] objectForKey:@"NO-DATA"] isEqualToString:@"NO"]) {
                NSArray *courses = [[NSArray alloc] initWithArray:[[myCourses objectAtIndex:(indexPath.section - PRESECTION + SemesterOffset)] objectForKey:@"Semester-Courses"] copyItems:YES];
                courseNumber.text = [[courses objectAtIndex:indexPath.row] objectForKey:@"Course-Code"];
                courseName.text = [[courses objectAtIndex:indexPath.row] objectForKey:@"Course-Name"];
                courseCredits.text = [[courses objectAtIndex:indexPath.row] objectForKey:@"Course-Credits"];
                courseScore.text = [[courses objectAtIndex:indexPath.row] objectForKey:@"Course-Score"];
                
                [courseType addTarget:self action:@selector(touchCourseTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
                courseType.tag = (indexPath.section + SemesterOffset) * 100 + indexPath.row;
                
                NSString *TAG = [[courses objectAtIndex:indexPath.row] objectForKey:@"CourseType-Tag"];
                if (TAG != nil) {
                    NSString *title = @"★";
                    switch ([TAG integerValue]) {
                        case 1:
                            title = @"○";
                            break;
                        case 2:
                            title = @"△";
                            break;
                        case 3:
                            title = @"☆";
                            break;
                        case 4:
                            title = @"●";
                            break;
                        case 5:
                            title = @"▲";
                            break;
                        case 6:
                            title = @"★";
                            break;
                        case 7:
                            title = @"略";
                            break;
                        default:
                            break;
                    }
                    [courseType setTitle:title forState:UIControlStateNormal];
                }
            }
            
            return cell;
        }
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = 0;
    switch (section) {
        case 0:
        {
            if ([[sectionControl objectAtIndex:section] integerValue] == 1) {
                if (isSAIP) {
                    numberOfRows = 3;
                }else{
                    numberOfRows = 2;
                }
            }
            else {
                numberOfRows = 0;
            }
        }
            break;
        case 1:
        {
            if ([[sectionControl objectAtIndex:section] integerValue] == 1) {
                numberOfRows = 6;
            }
            else {
                numberOfRows = 0;
            }
        }
            break;
        case 2:
        {
            if ([[sectionControl objectAtIndex:section] integerValue] == 1) {
                numberOfRows = (int)[LAECourses count];
            }
            else {
                numberOfRows = 0;
            }
        }
            break;
        default:
        {
            if ([[sectionControl objectAtIndex:section] integerValue] == 1) {
                if ([[[myCourses objectAtIndex:(section - PRESECTION + SemesterOffset)] objectForKey:@"NO-DATA"] isEqualToString:@"NO"]) {
                    NSArray *courses = [[NSArray alloc] initWithArray:[[myCourses objectAtIndex:(section - PRESECTION + SemesterOffset)] objectForKey:@"Semester-Courses"] copyItems:YES];
                    numberOfRows = (int)[courses count];
                }
            }
            else {
                numberOfRows = 0;
            }
        }
            break;
    }
    return numberOfRows;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:
(NSIndexPath *)indexPath {
    //NSLog(@"SEC = %d ROW = %d", (int)indexPath.section, (int)indexPath.row);
    if (indexPath.section != 0 && indexPath.section != 1 && indexPath.section != 2) {
        if (![userName isEqualToString:@""]) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSArray *courses = [[NSArray alloc] initWithArray:[[myCourses objectAtIndex:(indexPath.section - 2)] objectForKey:@"Semester-Courses"] copyItems:YES];
            
            [self performSegueWithIdentifier:@"pushCourseDetailSegue"
                                      sender:[courses objectAtIndex:indexPath.row]];

        }
        else
        {
            [self showErrorWithErrorCode:9997];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"pushCourseDetailSegue"])
    {
        CourseDetailTableViewController *vc = [segue destinationViewController];
        [vc setValue:[sender objectForKey:@"Course-Code"] forKey:@"courseCode"];
        [vc setValue:[sender objectForKey:@"Course-Name"] forKey:@"courseName"];
        [vc setValue:[sender objectForKey:@"Course-Teacher"] forKey:@"teacherName"];
        [vc setValue:myStudentID forKey:@"studentID"];
        [vc setValue:userName forKey:@"studentName"];
        [vc setValue:@"Y" forKey:@"canCriticize"];
    }
}

#pragma mark - Error Function

- (void) showErrorWithErrorCode:(int)errCode
{
    switch (errCode) {
        case 200:
        {
            [self loadDataFromFile];
            [courseTable reloadData];
            
            //[self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統提示"
                                                              message:@"課程更新成功\n<注意>資料以學校為準<注意>"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
            [self activityIndicatorSwitch:NO];

        }
            break;
        case 9997:
        {
            //            [self loadDataFromFile];
            //            [courseTable reloadData];
            
            //[self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"需要更新資料，請點選重新整理"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:@"確認", nil];
            caution.tag = 9999;
            [caution show];
        }
            break;
        case 9998:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"課程評分系統"
                                                              message:@"是否要評論這門課程？？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                                    otherButtonTitles:@"確認", nil];
            caution.tag = 9998;
            [caution show];
        }
            break;
        case 9999:
        {
//            [self loadDataFromFile];
//            [courseTable reloadData];
            
            //[self activityIndicatorSwitch:NO];
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統警告"
                                                              message:@"更新課程會使計算結果清除，需重新計算。\n請問是否要更新課程？？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                                    otherButtonTitles:@"確認", nil];
            caution.tag = 9999;
            [caution show];
        }
            break;
        case 997:
        {
            isLoggedIn = NO;
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"帳號已被鎖住"
                                                              message:@"請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
            [self activityIndicatorSwitch:NO];
        }
            break;
        case 998:
        {
            isLoggedIn = NO;
            isInProcess = NO;
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                              message:@"請檢查帳號密碼"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
            [self activityIndicatorSwitch:NO];
        }
            break;
        case 999:
        {
            isLoggedIn = NO;
            isInProcess = NO;
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統不穩定"
                                                              message:@"請稍後再試"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
            [self activityIndicatorSwitch:NO];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Save/Retrieve Function

- (void)saveAccountDataToFile {
    CourseCreditsModel *model = [[CourseCreditsModel alloc] init];
    [model storeMyCourseCreditsAndScores:myCourses];
    
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/errorLoginCount.plist"];
    //Dictionary
    NSMutableDictionary *accountDict = [[NSMutableDictionary alloc] init];

    [accountDict setObject:[NSString stringWithFormat:@"%d", errLoginCount] forKey:@"errLoginCount"];
    
    //Save Data
    [accountDict writeToFile:filePath atomically:YES];
    
    //File Path
    filePath = [documentFolder stringByAppendingFormat:@"/UserName.plist"];
    //Dictionary
    accountDict = [[NSMutableDictionary alloc] init];
    
    if (![userName isEqualToString:@""] && userName != nil) {
        //Save Data
        [accountDict setObject:userName forKey:@"User-Name"];
        [accountDict writeToFile:filePath atomically:YES];
    }

}

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
        userName = @"";
    }

}

#pragma mark - IBAction (Touch Function)

- (IBAction)touchHeaderBtn:(UIButton *)sender {
    if ([[sectionControl objectAtIndex:sender.tag] integerValue] == 1) {
        [sectionControl replaceObjectAtIndex:sender.tag withObject:@"0"];
    }
    else {
        [sectionControl replaceObjectAtIndex:sender.tag withObject:@"1"];
    }
    [courseTable reloadData];
}

- (IBAction)touchChangeDepartment:(UIButton *)sender {
    //NSLog(@"TOUCH  TAG : %ld", sender.tag);
    if (SAIPGroup != nil) {
        if ((currentSAIPGroup + 1) == [SAIPGroup count]) {
            currentSAIPGroup = 0;
        }
        else{
            currentSAIPGroup++;
        }
    }
    [courseTable reloadData];
}

- (IBAction)touchCourseTypeBtn:(UIButton *)sender {
    
    int section = (int)sender.tag / 100;
    int row = sender.tag % 100;
    
    NSString *TAG = [[[[myCourses objectAtIndex:(section - PRESECTION)] objectForKey:@"Semester-Courses"] objectAtIndex:row] objectForKey:@"CourseType-Tag"];
    
    if (TAG == nil) {
        [[[[myCourses objectAtIndex:(section - PRESECTION)] objectForKey:@"Semester-Courses"] objectAtIndex:row] setObject:@"1" forKey:@"CourseType-Tag"];
    }
    else
    {
        if (([TAG integerValue] + 1) > 7) {
            [[[[myCourses objectAtIndex:(section - PRESECTION)] objectForKey:@"Semester-Courses"] objectAtIndex:row] setObject:@"1" forKey:@"CourseType-Tag"];
        }
        else
        {
            NSString *newTAG = [NSString stringWithFormat:@"%d", (int)[TAG integerValue] + 1];
            [[[[myCourses objectAtIndex:(section - PRESECTION)] objectForKey:@"Semester-Courses"] objectAtIndex:row] setObject:newTAG forKey:@"CourseType-Tag"];
        }
    }

    [courseTable reloadData];
}

- (IBAction)touchRefreshBtn:(UIBarButtonItem *)sender {
    if (isInProcess == NO) {
        [self showErrorWithErrorCode:9999];
    }
}

#pragma mark - View Function

- (void) activityIndicatorSwitch:(BOOL)isActive
{
    self.view.userInteractionEnabled = !isActive;
    
    isInProcess = isActive;
    
    if (isActive) {
        coverLabel = [[UILabel alloc] initWithFrame:CGRectMake(ORIGIN_X, ORIGIN_Y, SCREEN_W, SCREEN_H)];
        coverLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5f];
        ActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        ActivityIndicator.center = CGPointMake(SCREEN_W / 2, 150.0);
        [ActivityIndicator startAnimating];
        [self.view addSubview:coverLabel];
        [self.view addSubview:ActivityIndicator];
    }
    else
    {
        [coverLabel removeFromSuperview];
        [ActivityIndicator removeFromSuperview];
    }
}

- (void) fetchSelfCourseDataAndScore
{
    [self activityIndicatorSwitch:YES];
    if (![self checkInternet])
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
        GraduationStandardAbstractor *standardAbstractor = [[GraduationStandardAbstractor alloc] init];
        
        CourseCreditsModel *model = [[CourseCreditsModel alloc] init];
        [model storeGraduationStandard:[standardAbstractor GetGraduationStandardOfYear:[[myStudentID substringToIndex:3]integerValue]]];
        
        if (isLoggedIn) {
            [self startFetchingFunctionWithLogin];
        }
        else
        {
            terminatedFlag = 0;
            [self startFetchingFunctionWithLogin];
        }
    }
}

- (void) startFetchingFunction
{
    NSString *URL = @"http://aps-stu.ntut.edu.tw/StuQuery/QryLAECourse.jsp";
    NSURL *url = [NSURL URLWithString:URL];
    [client startDownloadWithURL:url postData:nil cookie:cookieValue];
    currentStage = 5;
}

- (void) startFetchingFunctionWithLogin
{
    if (terminatedFlag < 10) {
        NSString *URL = @"http://nportal.ntut.edu.tw/authImage.do";
        NSURL *url = [NSURL URLWithString:URL];
        client = [[HttpPost alloc] initWithURL:url postData:@"" cookie:@"" timeout:5 delegate:self];
        [client startDownloadWithURL:url postData:@"" cookie:@""];
        currentStage = 0;
        failCount = 0;
    }
    else
    {
        [self showErrorWithErrorCode:999];
    }
}

#pragma mark - HTTP Post Delegate

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

- (void) httpPost:(HttpPost *)httpPost didReceiveResponseWithCookie:(NSString *)responseCookie
{
    if (![responseCookie isEqualToString:@""]) {
        cookieValue = responseCookie;
        NSLog(@"STAGE - %d, COOKIE = \"%@\"", currentStage, cookieValue);
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
                NSString *URL = @"http://nportal.ntut.edu.tw/ssoIndex.do?apUrl=http://aps-stu.ntut.edu.tw/StuQuery/LoginSID.jsp&apOu=aa_003&sso=big5&datetime1=1445338202033";
                NSURL *url = [NSURL URLWithString:URL];
                failCount = 0;
                //NSLog(@"%@", cookieValue);
                [client startDownloadWithURL:url postData:nil cookie:cookieValue];
                currentStage++;
            }
        }
            break;
        case 2:
        {
            //NSLog(@"%@", cookieValue);
            NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSString* newStr = [[NSString alloc] initWithData:fileData encoding:strEncode];
            NSLog(@"%@", newStr);
            NSString *szNeedle= @"<input type='hidden' name='sessionId' value='";
            NSRange range = [newStr rangeOfString:szNeedle];
            
            if (range.location == NSNotFound) {
                if (failCount > 100) {
                    currentStage = 999;
                }
                else
                {
                    NSString *URL = @"http://nportal.ntut.edu.tw/ssoIndex.do?apUrl=http://aps-stu.ntut.edu.tw/StuQuery/LoginSID.jsp&apOu=aa_003&sso=big5&datetime1=1445338202033";
                    NSURL *url = [NSURL URLWithString:URL];
                    
                    [client startDownloadWithURL:url postData:nil cookie:cookieValue];
                    failCount++;
                    //NSLog(@"fail:%d", failCount);
                }
            }
            else
            {
                NSInteger idx = range.location + range.length;
                NSString *sessionId = [newStr substringFromIndex:idx];
                szNeedle= @"'>";
                range = [sessionId rangeOfString:szNeedle];
                idx = range.location;
                sessionID = [sessionId substringToIndex:idx];
                NSString *URL = @"http://aps-stu.ntut.edu.tw/StuQuery/LoginSID.jsp";
                NSURL *url = [NSURL URLWithString:URL];
                sessionID = [sessionID stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
                sessionID = [sessionID stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
                NSString *post = [NSString stringWithFormat:@"sessionId=%@&userid=%@", sessionID ,myStudentID];
                
                [client startDownloadWithURL:url postData:post cookie:cookieValue];
                currentStage = 3;
            }
        }
            break;
        case 3:
        {
            NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSString* newStr = [[NSString alloc] initWithData:fileData encoding:strEncode];
            NSLog(@"%@", newStr);

            if ([fileData length] == 416) {
                isLoggedIn = YES;
                NSString *URL = @"http://aps-stu.ntut.edu.tw/StuQuery/StudentQuery.jsp";
                NSURL *url = [NSURL URLWithString:URL];
                [client startDownloadWithURL:url postData:nil cookie:cookieValue];
                
                currentStage = 4;
            }
            else
            {
                isLoggedIn = NO;
                terminatedFlag++;
                [self performSelector:@selector(startFetchingFunctionWithLogin) withObject:nil afterDelay:3.0];
            }
        }
            break;
        case 4:
        {
            NSString *URL = @"http://aps-stu.ntut.edu.tw/StuQuery/QryLAECourse.jsp";
            NSURL *url = [NSURL URLWithString:URL];
            [client startDownloadWithURL:url postData:nil cookie:cookieValue];
            currentStage = 5;
        }
            break;
        case 5:
        {
            NSStringEncoding strEncode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5);
            NSString *dataContent = [[NSString alloc] initWithData:fileData encoding:strEncode];
            
            LAECourseDataAbstractor *abstractor = [[LAECourseDataAbstractor alloc] init];
            CourseCreditsModel *model = [[CourseCreditsModel alloc] init];
            [model storeMyLAECourseCredits:[abstractor returnLAECourseDictionaryWithDataString:dataContent]];
            
            NSString *URL = @"http://aps-stu.ntut.edu.tw/StuQuery/QryScore.jsp";
            NSURL *url = [NSURL URLWithString:URL];
            NSString *post = [NSString stringWithFormat:@"format=-2"];
            [client startDownloadWithURL:url postData:post cookie:cookieValue];
            currentStage++;
        }
            break;
        case 6:
        {
            isRefreshData = YES;
            QueryScoreDataAbstractor *abstractor = [[QueryScoreDataAbstractor alloc] init];
            CourseCreditsModel *model = [[CourseCreditsModel alloc] init];
            [model storeMyCourseCreditsAndScores:[abstractor returnScoreDataWithString:fileData]];
            
            [self showErrorWithErrorCode:200];
            
            
        }
            break;
        case 999:
        {
            isLoggedIn = NO;
            
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

#pragma mark - Alert View Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 9999:
        {
            switch (buttonIndex) {
                case 0:
                {
                    
                }
                    break;
                case 1:
                {
                    [self fetchSelfCourseDataAndScore];
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

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
