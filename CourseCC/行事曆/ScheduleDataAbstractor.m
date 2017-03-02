//
//  ScheduleDataAbstractor.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/8/10.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "ScheduleDataAbstractor.h"

@implementation ScheduleDataAbstractor

- (NSArray *)scheduleOfMonth:(NSInteger)month
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"104NTUT_Schedule"
                                                     ofType:@"txt"];
    NSString* txtContent = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *monthlyContent = [txtContent componentsSeparatedByString:@"----------"];
    NSString *specContent = [monthlyContent objectAtIndex:(month - 1)];
    NSArray *dataArray = [specContent componentsSeparatedByString:@"\n"];
    NSMutableArray *scheduleOfSpecMonth = [[NSMutableArray alloc] init];
    
    for (NSString *data in dataArray) {
        if ([data length] != 0) {
            NSMutableDictionary *dataDict = [[NSMutableDictionary alloc] init];
            NSString *dashSign = @"-";
            NSRange searchRange = [data rangeOfString:dashSign];
            if (searchRange.location == NSNotFound) {
                NSArray *sepData = [data componentsSeparatedByString:@"]"];
                [dataDict setObject:[sepData objectAtIndex:1] forKey:@"Event-Detail"];
                NSString *date = [[sepData objectAtIndex:0] substringFromIndex:1];
                NSArray *dateArray = [date componentsSeparatedByString:@"/"];
                NSString *MM = [dateArray objectAtIndex:0];
                NSString *DD = [dateArray objectAtIndex:1];
                NSString *YYYY = @"2015";
                if ([MM integerValue] < 8) {
                    YYYY = @"2016";
                }
                [dataDict setObject:YYYY forKey:@"Event-Year"];
                [dataDict setObject:MM forKey:@"Event-Month"];
                [dataDict setObject:DD forKey:@"Event-Day"];
                [dataDict setObject:@"NO" forKey:@"IsPeriod"];
                [scheduleOfSpecMonth addObject:dataDict];
            }
            else
            {
                NSArray *sepData = [data componentsSeparatedByString:@"]"];
                [dataDict setObject:[sepData objectAtIndex:1] forKey:@"Event-Detail"];
                NSArray *dateArray = [[sepData objectAtIndex:0] componentsSeparatedByString:@"-"];
                NSString *date = [[dateArray objectAtIndex:0] substringFromIndex:1];
                NSArray *sepDate = [date componentsSeparatedByString:@"/"];
                NSString *endDate = [dateArray objectAtIndex:1];
                
                NSString *MM = [sepDate objectAtIndex:0];
                NSString *DD = [sepDate objectAtIndex:1];
                NSString *YYYY = @"2015";
                if ([MM integerValue] < 8) {
                    YYYY = @"2016";
                }
                [dataDict setObject:YYYY forKey:@"Event-Year"];
                [dataDict setObject:MM forKey:@"Event-Month"];
                [dataDict setObject:DD forKey:@"Event-Day"];
                
                MM = [[endDate componentsSeparatedByString:@"/"] objectAtIndex:0];
                DD = [[endDate componentsSeparatedByString:@"/"] objectAtIndex:1];
                YYYY = @"2015";
                if ([MM integerValue] < 8) {
                    YYYY = @"2016";
                }
                [dataDict setObject:YYYY forKey:@"Event-Year-END"];
                [dataDict setObject:MM forKey:@"Event-Month-END"];
                [dataDict setObject:DD forKey:@"Event-Day-END"];
                
                [dataDict setObject:@"YES" forKey:@"IsPeriod"];
                [scheduleOfSpecMonth addObject:dataDict];
            }
        }
    }
    
    return scheduleOfSpecMonth;
}

@end
