//
//  CourseCreditsModel.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/6.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseCreditsModel.h"

@implementation CourseCreditsModel

- (void)storeMyLAECourseCredits:(NSArray *)LAECourses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myLAECourses.plist"];
    [LAECourses writeToFile:filePath atomically:YES];
}

- (void)storeMyCourseCreditsAndScores:(NSArray *)Courses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCoursesAndScores.plist"];
    [Courses writeToFile:filePath atomically:YES];
}

- (void)storeGraduationStandard:(NSArray *)graduationStandard
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myGraduationStandard.plist"];
    [graduationStandard writeToFile:filePath atomically:YES];
}

- (NSArray *)readMyLAECourseCredits
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myLAECourses.plist"];
    
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        return [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)readMyCourseAndScore
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCoursesAndScores.plist"];
    
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        return [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        return nil;
    }
}

- (NSArray *)readGraduationStandard
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/myGraduationStandard.plist"];
    
    //Check if the file exists
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists)
    {
        return [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        return nil;
    }
}

@end
