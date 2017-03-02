//
//  LAECourseDataAbstractor.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/5.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "LAECourseDataAbstractor.h"

@implementation LAECourseDataAbstractor

- (NSArray *)returnLAECourseDictionaryWithDataString:(NSString *)dataString
{
    dataString = [dataString stringByReplacingOccurrencesOfString:@" " withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"　" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    NSString *szNeedle= @"<tr><tdALIGN=CENTERROWSPAN=";
    NSRange range = [dataString rangeOfString:szNeedle];
    NSInteger startIdx = range.location;
    szNeedle= @"</table><br>";
    range = [dataString rangeOfString:szNeedle];
    NSInteger endIdx = range.location;
    dataString = [[dataString substringToIndex:endIdx] substringFromIndex:startIdx];
    
    //NSLog(@"%@", dataString);
    
    NSMutableArray *LAEAspect = [[NSMutableArray alloc] init];
    
    for (int count = 0; count < 8; count++) {
        NSString *stringOfAspect = [[NSString alloc] init];
        NSString *courseAspect = [[NSString alloc] init];
        szNeedle= @"\">";
        range = [dataString rangeOfString:szNeedle];
        startIdx = range.location + range.length;
        szNeedle= @"</a>";
        range = [dataString rangeOfString:szNeedle];
        endIdx = range.location;
        
        NSMutableDictionary *LAECourse = [[NSMutableDictionary alloc] init];
        courseAspect = [[dataString substringToIndex:endIdx] substringFromIndex:startIdx];
        [LAECourse setObject:courseAspect forKey:@"Course-Aspect"];
        
        if (count == 7) {
            stringOfAspect = dataString;
        }
        else
        {
            szNeedle= @"</a>";
            range = [dataString rangeOfString:szNeedle];
            startIdx = range.location + range.length;
            stringOfAspect = [dataString substringFromIndex:startIdx];
            range = [stringOfAspect rangeOfString:szNeedle];
            endIdx = range.location;
            stringOfAspect = [stringOfAspect substringToIndex:endIdx];
            
            szNeedle= @"</a>";
            range = [dataString rangeOfString:szNeedle];
            startIdx = range.location + range.length;
            dataString = [dataString substringFromIndex:startIdx];
        }
        
        
        for (int i = 0; i < 3; i++) {
            szNeedle= @"<tdALIGN=CENTERROWSPAN=";
            range = [stringOfAspect rangeOfString:szNeedle];
            startIdx = range.location + range.length;
            stringOfAspect = [stringOfAspect substringFromIndex:startIdx];
            
            szNeedle= @">";
            range = [stringOfAspect rangeOfString:szNeedle];
            startIdx = range.location + range.length;
            szNeedle= @"<td";
            range = [stringOfAspect rangeOfString:szNeedle];
            endIdx = range.location;
            
            switch (i) {
                case 0:
                {
                    [LAECourse setObject:[[stringOfAspect substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Supposed-Credits"];
                }
                    break;
                case 1:
                {
                    [LAECourse setObject:[[stringOfAspect substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Actual-Credits"];
                }
                    break;
                case 2:
                {
                    [LAECourse setObject:[[stringOfAspect substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Addition-Credits"];
                }
                    break;
                default:
                    break;
            }
        }
        
        if (![[LAECourse objectForKey:@"Actual-Credits"] isEqualToString:@""] || ![LAECourse objectForKey:@"Addition-Credits"]) {
            NSArray *Courses = [stringOfAspect componentsSeparatedByString:@"</tr>"];
            NSMutableArray *selectedCourses = [[NSMutableArray alloc] init];
            for (int i = 0; i < [Courses count] - 1; i++) {
                NSMutableDictionary *courseData = [[NSMutableDictionary alloc] init];
                NSString *courseStr = [Courses objectAtIndex:i];
                for (int j = 0; j < 6; j++) {
                    NSString *stringAbstract;
                    switch (j) {
                        case 0:
                        {
                            szNeedle= @"<tdALIGN=CENTER>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            
                            szNeedle= @"<";
                            range = [courseStr rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            stringAbstract = [courseStr substringToIndex:endIdx];
                            [courseData setObject:stringAbstract forKey:@"Year-Sem"];
                        }
                            break;
                        case 1:
                        {
                            szNeedle= @"<tdALIGN=CENTER>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            
                            szNeedle= @"<";
                            range = [courseStr rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            stringAbstract = [courseStr substringToIndex:endIdx];
                            [courseData setObject:stringAbstract forKey:@"Core"];
                            
                        }
                            break;
                        case 2:
                        {
                            szNeedle= @"<tdALIGN=CENTER>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            
                            szNeedle= @"<";
                            range = [courseStr rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            stringAbstract = [courseStr substringToIndex:endIdx];
                            [courseData setObject:stringAbstract forKey:@"Course-Code"];
                        }
                            break;
                        case 3:
                        {
                            szNeedle= @"<tdALIGN=LEFT>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            
                            szNeedle= @"<";
                            range = [courseStr rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            stringAbstract = [courseStr substringToIndex:endIdx];
                            [courseData setObject:stringAbstract forKey:@"Course-Name"];
                        }
                            break;
                        case 4:
                        {
                            szNeedle= @"<tdALIGN=CENTER>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            
                            szNeedle= @"<";
                            range = [courseStr rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            stringAbstract = [courseStr substringToIndex:endIdx];
                            [courseData setObject:stringAbstract forKey:@"Course-Credits"];
                        }
                            break;
                        case 5:
                        {
                            szNeedle= @"<tdALIGN=CENTER>";
                            range = [courseStr rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            courseStr = [courseStr substringFromIndex:startIdx];
                            [courseData setObject:courseStr forKey:@"Course-Score"];
                        }
                            break;
                        default:
                            break;
                    }
                }
                [selectedCourses addObject:courseData];
            }
            [LAECourse setObject:selectedCourses forKey:@"Selected-Courses"];
        }
        
        [LAEAspect addObject:LAECourse];
    }
    return LAEAspect;
}

@end
