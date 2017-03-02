//
//  CourseCreditsModel.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/6.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseCreditsModel : NSObject

- (void)storeMyLAECourseCredits:(NSArray *)LAECourses;

- (void)storeMyCourseCreditsAndScores:(NSArray *)Courses;

- (void)storeGraduationStandard:(NSArray *)graduationStandard;

- (NSArray *)readMyLAECourseCredits;

- (NSArray *)readMyCourseAndScore;

- (NSArray *)readGraduationStandard;

@end
