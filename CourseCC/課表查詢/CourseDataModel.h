//
//  CourseDataModel.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/4/17.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseDataModel : NSObject

- (void)storeMyCourseWithYearCourses:(NSArray *)YearCourses myCourse:(BOOL)isMyCourses;
- (NSArray *)readCoursesFromFile:(BOOL)isMyCourses;
- (void)storeMyCourseWithYearCoursesTitle:(NSArray *)YearCourses myCourse:(BOOL)isMyCourses;
- (NSArray *)readCoursesTitleFromFile:(BOOL)isMyCourses;

@end
