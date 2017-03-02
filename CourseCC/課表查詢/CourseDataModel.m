//
//  CourseDataModel.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/4/17.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "CourseDataModel.h"

@implementation CourseDataModel

- (void)storeMyCourseWithYearCourses:(NSArray *)YearCourses myCourse:(BOOL)isMyCourses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    if (isMyCourses) {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCourses.plist"];
        [YearCourses writeToFile:filePath atomically:YES];
    }
    else
    {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/checkCourses.plist"];
        [YearCourses writeToFile:filePath atomically:YES];
    }
}

- (void)storeMyCourseWithYearCoursesTitle:(NSArray *)YearCourses myCourse:(BOOL)isMyCourses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    if (isMyCourses) {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCoursesTitle.plist"];
        [YearCourses writeToFile:filePath atomically:YES];
    }
    else
    {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/checkCoursesTitle.plist"];
        [YearCourses writeToFile:filePath atomically:YES];
    }
}

- (NSArray *)readCoursesFromFile:(BOOL)isMyCourses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    if (isMyCourses) {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCourses.plist"];
        return [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/checkCourses.plist"];
        return [NSArray arrayWithContentsOfFile:filePath];
    }
}

- (NSArray *)readCoursesTitleFromFile:(BOOL)isMyCourses
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    if (isMyCourses) {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/myCoursesTitle.plist"];
        return [NSArray arrayWithContentsOfFile:filePath];
    }
    else
    {
        NSString *filePath = [documentFolder stringByAppendingFormat:@"/checkCoursesTitle.plist"];
        return [NSArray arrayWithContentsOfFile:filePath];
    }
}


@end
