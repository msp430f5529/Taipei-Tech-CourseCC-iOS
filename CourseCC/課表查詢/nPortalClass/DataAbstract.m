//
//  DataAbstract.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/4/18.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "DataAbstract.h"

@implementation DataAbstract

-(id) init;
{
    self = [super init];
    
    if (self) {
        
    }
    return  self;
}

-(NSArray *)outputCoursesWithData:(NSString *)dataInput
{
    NSMutableArray *courses;
    //NSLog(@"%@", [self abstractHTMLofCourseTable:dataInput]);
    courses = [[NSMutableArray alloc] initWithArray:[self abstractToArrayWithCourseTable:[self abstractHTMLofCourseTable:dataInput]]];
    return courses;
}

-(NSArray *)abstractToArrayWithCourseTable:(NSString *)HTMLCode
{
    //NSLog(@"%@", HTMLCode);
    NSString *szNeedle= @"<tr>";
    NSRange range = [HTMLCode rangeOfString:szNeedle];
    NSMutableArray *courseArray = [[NSMutableArray alloc] init];
    int count = 0;
    while (range.location != NSNotFound) {
        count++;
        //NSLog(@"%d", count);
        HTMLCode = [HTMLCode substringFromIndex:(range.location + range.length)];
        NSMutableDictionary *courseInfo = [[NSMutableDictionary alloc] init];
        NSMutableArray *classPeriod = [[NSMutableArray alloc] init];
        for (int i = 0; i < 21; i++) {
            NSString *searchStr = @"班週會及導師時間";
            NSRange searchRangeStart = [HTMLCode rangeOfString:searchStr];
            NSRange searchRangeEnd = [HTMLCode rangeOfString:searchStr];
            if (searchRangeStart.location != NSNotFound) {
                [courseInfo setObject:@"班週會及導師時間" forKey:@"Course-Name"];
                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 1 + 3)]];
                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 1 + 4)]];
                break;
            }
            else{
                switch (i) {
                    case 0:
                    {
                        searchStr = @"\">";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"</A>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Number"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 1:
                    {
                        searchStr = @"<Ahref=\"Curr.jsp?format=-2&code=";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"\">";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Code"];
                        
                        searchStr = @"\">";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"</A><td";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Name"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 2:
                    {
                        searchStr = @"align=CENTER>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"<td";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Term"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 3:
                    {
                        searchStr = @"align=CENTER>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"<td";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Credits"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 4:
                    {
                        searchStr = @"align=CENTER>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"<td";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Hours"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 5:
                    {
                        searchStr = @"</div>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 6:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *teacherArray = [[NSMutableArray alloc] init];
                        
                        searchStr = @"\">";
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        
                        while (searchRangeStart.location != NSNotFound)
                        {
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                            searchStr = @"</A><BR>";
                            searchRangeEnd = [strForAbstract rangeOfString:searchStr];
                            [teacherArray addObject:[[strForAbstract substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)]];
                            strForAbstract = [strForAbstract substringFromIndex:searchRangeEnd.location + searchRangeEnd.length];
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        }
                        
                        [courseInfo setObject:teacherArray forKey:@"Course-Teacher"];
                    }
                        break;
                    case 7:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *classArray = [[NSMutableArray alloc] init];
                        
                        searchStr = @"\">";
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        
                        while (searchRangeStart.location != NSNotFound)
                        {
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                            searchStr = @"</A><BR>";
                            searchRangeEnd = [strForAbstract rangeOfString:searchStr];
                            [classArray addObject:[[strForAbstract substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)]];
                            strForAbstract = [strForAbstract substringFromIndex:searchRangeEnd.location + searchRangeEnd.length];
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        }
                        
                        [courseInfo setObject:classArray forKey:@"Course-Class"];
                    }
                        break;
                    case 8:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 6 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 9:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 0 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 10:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 1 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 11:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 2 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 12:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 3 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 13:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 4 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 14:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[strForAbstract length]];
                        for (int i=0; i < [strForAbstract length]; i++) {
                            NSString *ichar  = [NSString stringWithFormat:@"%c", [strForAbstract characterAtIndex:i]];
                            int asciiCode = [ichar characterAtIndex:0];
                            if (asciiCode >= 65 && asciiCode <= 68) {
                                ichar = [NSString stringWithFormat:@"%d", ([ichar characterAtIndex:0] - 55)];
                            }
                            [characters addObject:ichar];
                        }
                        
                        if ([characters count] != 0) {
                            for (NSString *ichar in characters) {
                                [classPeriod addObject:[NSString stringWithFormat:@"%d", (13 * 5 + [ichar intValue])]];
                            }
                        }
                    }
                        break;
                    case 15:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        NSString *strForAbstract = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        strForAbstract = [strForAbstract substringToIndex:searchRangeStart.location];
                        
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.length + searchRangeStart.location];
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeStart.location];
                        
                        NSMutableArray *classroomArray = [[NSMutableArray alloc] init];
                        
                        searchStr = @"\">";
                        searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        
                        while (searchRangeStart.location != NSNotFound)
                        {
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                            searchStr = @"</A><BR>";
                            searchRangeEnd = [strForAbstract rangeOfString:searchStr];
                            [classroomArray addObject:[[strForAbstract substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)]];
                            strForAbstract = [strForAbstract substringFromIndex:searchRangeEnd.location + searchRangeEnd.length];
                            searchStr = @"\">";
                            searchRangeStart = [strForAbstract rangeOfString:searchStr];
                        }
                        
                        [courseInfo setObject:classroomArray forKey:@"Course-Classroom"];
                    }
                        break;
                    case 16:
                    {
                        searchStr = @"撤選";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        if (searchRangeEnd.location != NSNotFound) {
                            [courseInfo setObject:@"Y" forKey:@"Course-Withdraw"];
                        }
                        else
                        {
                            [courseInfo setObject:@"N" forKey:@"Course-Withdraw"];
                        }
                        searchStr = @"</div>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 17:
                    {
                        searchStr = @"<td>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 18:
                    {
                        searchStr = @"<tdalign=CENTER>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 19:
                    {
                        searchStr = @"<tdalign=center>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    case 20:
                    {
                        searchStr = @"<td>";
                        searchRangeStart = [HTMLCode rangeOfString:searchStr];
                        searchStr = @"</tr>";
                        searchRangeEnd = [HTMLCode rangeOfString:searchStr];
                        [courseInfo setObject:[[HTMLCode substringToIndex:searchRangeEnd.location] substringFromIndex:(searchRangeStart.location + searchRangeStart.length)] forKey:@"Course-Memo"];
                        HTMLCode = [HTMLCode substringFromIndex:searchRangeEnd.length + searchRangeEnd.location];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
        [courseInfo setObject:classPeriod forKey:@"Class-Period"];
        [courseArray addObject:courseInfo];
        range = [HTMLCode rangeOfString:szNeedle];
    }
    return courseArray;
}

-(NSString *)abstractHTMLofCourseTable:(NSString *)HTMLCode
{
    NSString *szNeedle= @"<th>備註";
    NSRange range = [HTMLCode rangeOfString:szNeedle];
    NSInteger idx = range.location + range.length;
    NSString *abstractData = [HTMLCode substringFromIndex:idx];
    szNeedle= @"<tr><td>小計<td>";
    range = [abstractData rangeOfString:szNeedle];
    idx = range.location;
    abstractData = [abstractData substringToIndex:idx];
    
    abstractData = [abstractData stringByReplacingOccurrencesOfString:@" " withString:@""];
    abstractData = [abstractData stringByReplacingOccurrencesOfString:@"　" withString:@""];
    abstractData = [abstractData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    abstractData = [abstractData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    return abstractData;
}

@end
