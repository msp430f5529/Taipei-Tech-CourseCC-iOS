//
//  QueryScoreDataAbstractor.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/6.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "QueryScoreDataAbstractor.h"

@implementation QueryScoreDataAbstractor

- (NSArray *)returnScoreDataWithString:(NSData *)data
{
    NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
    NSString *dataString = [[NSString alloc] initWithData:data encoding:big5];
    
    //NSLog(@"%@", dataString);
    NSString *szNeedle= @"</H3>";
    NSRange range = [dataString rangeOfString:szNeedle];
    NSInteger startIdx = range.location + range.length;
    dataString = [dataString substringFromIndex:startIdx];
    
    szNeedle= @"<Center><Font size=4 color=red></Font></Center>";
    range = [dataString rangeOfString:szNeedle];
    NSInteger endIdx = range.location;
    dataString = [dataString substringToIndex:endIdx];
    
    //NSLog(@"%@", dataString);
    
    dataString = [dataString stringByReplacingOccurrencesOfString:@" " withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"　" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    //NSLog(@"%@", dataString);
    
    NSArray *semesterDataArray = [dataString componentsSeparatedByString:@"<br><H3><imgsrc=./image/or_ball.gif>"];
    NSMutableArray *semesterArray = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < [semesterDataArray count]; i++) {
        NSMutableDictionary *semesterDict = [[NSMutableDictionary alloc] init];
        NSString *semesterString = [semesterDataArray objectAtIndex:i];
        szNeedle= @"</H3>";
        range = [semesterString rangeOfString:szNeedle];
        NSString *semesterTitle = [semesterString substringToIndex:range.location];
        [semesterDict setObject:semesterTitle forKey:@"Semester-Title"];
        
        szNeedle= @"查無";
        range = [semesterString rangeOfString:szNeedle];
        
        if (range.location == NSNotFound) {
            [semesterDict setObject:@"NO" forKey:@"NO-DATA"];
            
            szNeedle= @"備註";
            range = [semesterString rangeOfString:szNeedle];
            semesterString = [semesterString substringFromIndex:range.location + range.length];
            
            NSArray *coursesData = [semesterString componentsSeparatedByString:@"<tr><thcolspan=8>"];
            NSArray *courses = [[coursesData objectAtIndex:0] componentsSeparatedByString:@"<tr>"];
            //NSLog(@"%@", [coursesData objectAtIndex:0]);
            
            NSMutableArray *AbstractedCourses = [[NSMutableArray alloc] init];
            
            for (int courseCount = 1; courseCount < [courses count]; courseCount++) {
                NSMutableDictionary *courseDict = [[NSMutableDictionary alloc] init];
                NSString *courseString = [courses objectAtIndex:courseCount];
                for (int j = 0; j < 8; j++) {
                    switch (j) {
                        case 0:
                        {
                            szNeedle= @"<thalign=Right>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            szNeedle= @"<th>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[[courseString substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Course-Num"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 1:
                        {
                            szNeedle= @"<th>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            szNeedle= @"<thalign=Left>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[[courseString substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Course-Type"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 2:
                        {
                            szNeedle= @"Curr.jsp?format=-2&code=";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            szNeedle= @"\">";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[[courseString substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Course-Code"];
                            
                            szNeedle= @"\">";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            szNeedle= @"</a>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[[courseString substringToIndex:endIdx] substringFromIndex:startIdx] forKey:@"Course-Name"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 3:
                        {
                            szNeedle= @"</a><thalign=Center>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            courseString = [courseString substringFromIndex:startIdx];
                            
                            szNeedle= @"<thalign=Center>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[courseString substringToIndex:endIdx] forKey:@"Course-FileNumber"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 4:
                        {
                            szNeedle= @"<thalign=Center>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            courseString = [courseString substringFromIndex:startIdx];
                            
                            szNeedle= @"<thalign=Right>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[courseString substringToIndex:endIdx] forKey:@"Course-Term"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 5:
                        {
                            szNeedle= @"<thalign=Right>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            courseString = [courseString substringFromIndex:startIdx];
                            
                            szNeedle= @"<thalign=Right>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[courseString substringToIndex:endIdx] forKey:@"Course-Credits"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 6:
                        {
                            szNeedle= @"<thalign=Right>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.length + range.location;
                            courseString = [courseString substringFromIndex:startIdx];
                            
                            szNeedle= @"<td>";
                            range = [courseString rangeOfString:szNeedle];
                            endIdx = range.location;
                            
                            [courseDict setObject:[courseString substringToIndex:endIdx] forKey:@"Course-Score"];
                            
                            courseString = [courseString substringFromIndex:endIdx];
                        }
                            break;
                        case 7:
                        {
                            szNeedle= @"<td>";
                            range = [courseString rangeOfString:szNeedle];
                            startIdx = range.location + range.length;
                            
                            [courseDict setObject:[courseString substringFromIndex:startIdx] forKey:@"Course-Memo"];
                        }
                            break;
                        default:
                            break;
                    }
                }
                [AbstractedCourses addObject:courseDict];
            }
            [semesterDict setObject:AbstractedCourses forKey:@"Semester-Courses"];
        }
        else
        {
            [semesterDict setObject:@"YES" forKey:@"NO-DATA"];
        }
        [semesterArray addObject:semesterDict];
    }
    
    return semesterArray;
}

@end
