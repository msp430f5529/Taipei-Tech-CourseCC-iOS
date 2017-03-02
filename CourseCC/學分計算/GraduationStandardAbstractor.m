//
//  GraduationStandardAbstractor.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/8/14.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "GraduationStandardAbstractor.h"

@implementation GraduationStandardAbstractor
{
    
}

- (NSArray *)GetGraduationStandardOfYear:(NSInteger)year
{
    NSMutableArray *departmentArray = [[NSMutableArray alloc] init];
    NSString *dataContent = [self downloadGraudationStandardOfYear:year];
    NSString *searchString = @"<th width=50>最低畢業學分數";
    NSRange searchRange = [dataContent rangeOfString:searchString];
    
    dataContent = [dataContent substringFromIndex:searchRange.location + searchRange.length];
    
    //NSLog(@"%@", dataContent);
    
    searchString = @"matric=7&division=";
    searchRange = [dataContent rangeOfString:searchString];

    while (searchRange.location != NSNotFound) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        searchString = @"matric=7&division=";
        searchRange = [dataContent rangeOfString:searchString];
        dataContent = [dataContent substringFromIndex:searchRange.location + searchRange.length];
        
        searchString = @"<tr><td><P>";
        searchRange = [dataContent rangeOfString:searchString];
        NSString *depString = @"";
        
        if (searchRange.location != NSNotFound) {
            depString = [dataContent substringToIndex:searchRange.location];
        }
        else
        {
            searchString = @"</table>";
            searchRange = [dataContent rangeOfString:searchString];
            depString = [dataContent substringToIndex:searchRange.location];
        }
        
        depString = [depString stringByReplacingOccurrencesOfString:@" " withString:@""];
        depString = [depString stringByReplacingOccurrencesOfString:@"　" withString:@""];
        depString = [depString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        depString = [depString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        
        //NSLog(@"%@", depString);
        
        NSString *departmentCode = [depString substringToIndex:3];
        [dict setObject:departmentCode forKey:@"DEP-CODE"];
        searchString = @"</A>";
        searchRange = [depString rangeOfString:searchString];
        [dict setObject:[[depString substringToIndex:searchRange.location] substringFromIndex:5] forKey:@"DEP-NAME"];
        depString = [depString substringFromIndex:searchRange.location + searchRange.length];
        //NSLog(@"%@", depString);
        
        for (int count = 0; count < 8; count++) {
            searchString = @"<tdalign=center>";
            searchRange = [depString rangeOfString:searchString];
            NSString *credits = @"";
            if (count < 7) {
                depString = [depString substringFromIndex:searchRange.length + searchRange.location];
                searchString = @"<tdalign=center>";
                searchRange = [depString rangeOfString:searchString];
                credits = [depString substringToIndex:searchRange.location];
            }
            else
            {
                depString = [depString substringFromIndex:searchRange.length + searchRange.location];
                credits = depString;
            }
            
            switch (count) {
                case 0:
                    [dict setObject:credits forKey:@"DEP-REQ"];
                    break;
                case 1:
                    [dict setObject:credits forKey:@"SCH-REQ"];
                    break;
                case 2:
                    [dict setObject:credits forKey:@"SCH-SEL"];
                    break;
                case 3:
                    [dict setObject:credits forKey:@"DEP-PRO"];
                    break;
                case 4:
                    [dict setObject:credits forKey:@"SCH-PRO"];
                    break;
                case 5:
                    [dict setObject:credits forKey:@"PRO-SEL"];
                    break;
                case 6:
                    [dict setObject:credits forKey:@"CROSS-DEP"];
                    break;
                case 7:
                    [dict setObject:credits forKey:@"TOTAL-CREDITS"];
                    break;
                default:
                    break;
            }
        }
        
        [departmentArray addObject:dict];
        
        searchString = @"matric=7&division=";
        searchRange = [dataContent rangeOfString:searchString];
    }
    
    return departmentArray;
}

- (NSString *)downloadGraudationStandardOfYear:(NSInteger)year
{
    NSString *URL = [NSString stringWithFormat:@"http://aps.ntut.edu.tw/course/tw/Cprog.jsp?format=-3&year=%ld&matric=7", year];
    NSURL *url = [NSURL URLWithString:URL];
    NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
    NSString *htmlData = [NSString stringWithContentsOfURL:url encoding:big5 error:nil];
    return htmlData;
}

@end
