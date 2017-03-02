//
//  SchoolScheduleModel.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/4.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "SchoolScheduleModel.h"

@implementation SchoolScheduleModel

- (void) saveDataToModelWithString:(NSString *)stringInput
{
    NSString *calendarData = [self CalendarString:stringInput];
    calendarData = [calendarData stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    calendarData = [calendarData stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSMutableArray *monthlyDataArray = [[NSMutableArray alloc] init];
    [monthlyDataArray removeAllObjects];
    
    NSString *dataString = calendarData;
    NSString *monthlyData = @"";
    
    NSString *startIndex = @"<td height=\"92\" valign=\"top\" bgcolor=\"#FFFF00\"><p>";
    NSString *endIndex = @"</p></td></tr></table></td></tr><trbgcolor=\"#FFFFFF\"><tdheight=\"30\"bgcolor=\"#CCCCCC\"class=\"style4\">";
    NSRange range = [dataString rangeOfString:startIndex];
    NSInteger startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    NSInteger endIdx = range.location;
    
    monthlyData = [dataString substringToIndex:endIdx];
    //NSLog(@"substring: %@", monthlyData);
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:8]];
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    
    //NSLog(@"dataString: %@ \n\n", dataString);
    
    startIndex = @"<tdheight=\"216\"valign=\"top\"bgcolor=\"#FFFFFF\"><p>";
    endIndex = @"</p></td></tr></table></td></tr><trbgcolor=\"#FFFFFF\"><tdheight=\"30\"bgcolor=\"#CCCCCC\"class=\"style4\">";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    //NSLog(@"substring: %@", monthlyData);
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:9]];
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    //NSLog(@"dataString: %@ \n\n", dataString);
    
    startIndex = @"<tablewidth=\"383\"height=\"155\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"bgcolor=\"#FFFF00\"><p>";
    endIndex = @"</p></td></tr></table>";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    //NSLog(@"substring: %@", monthlyData);
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
    
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    //NSLog(@"dataString: %@ \n\n", dataString);
    
    startIndex = @"<tablewidth=\"383\"height=\"155\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"><p>";
    endIndex = @"</p></td></tr></table>";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    monthlyData = [@"(" stringByAppendingString:monthlyData];
    //NSLog(@"substring: %@", monthlyData);
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
    
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    //NSLog(@"dataString: %@ \n\n", dataString);
    
    startIndex = @"<tablewidth=\"383\"height=\"145\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"bgcolor=\"#FFFF00\"><p>";
    endIndex = @"</p></td></tr></table>";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    //NSLog(@"substring: %@", monthlyData);
    
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
    
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    //NSLog(@"dataString: %@ \n\n", dataString);
    
    startIndex = @"<tablewidth=\"383\"height=\"145\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"><p>";
    endIndex = @"</p></td></tr></table>";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    monthlyData = [@"(" stringByAppendingString:monthlyData];
    //NSLog(@"substring: %@", monthlyData);
    
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
    
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    
    startIndex = @"<tablewidth=\"383\"height=\"145\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"bgcolor=\"#99FF00\"><p>";
    endIndex = @"</p></td></tr></table>";
    range = [dataString rangeOfString:startIndex];
    startIdx = range.length + range.location;
    range = [dataString rangeOfString:endIndex];
    endIdx = range.location;
    monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    //NSLog(@"substring: %@", monthlyData);
    
    [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
    
    dataString = [dataString substringFromIndex:(endIdx + range.length)];
    
    for (int i  = 0; i < 5; i++) {
        startIndex = @"<tablewidth=\"383\"height=\"145\"border=\"0\"cellpadding=\"5\"cellspacing=\"0\"><tr><tdvalign=\"top\"><p>";
        endIndex = @"</p></td></tr></table>";
        range = [dataString rangeOfString:startIndex];
        startIdx = range.length + range.location;
        range = [dataString rangeOfString:endIndex];
        endIdx = range.location;
        monthlyData = [[dataString substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
        //NSLog(@"substring: %@", monthlyData);
        
        [monthlyDataArray addObject:[self dataToArrayWithDataString:monthlyData inMonth:10]];
        
        dataString = [dataString substringFromIndex:(endIdx + range.length)];
    }
    
    NSMutableArray *MonthlyScheduleDataArray = [[NSMutableArray alloc] init];
    [MonthlyScheduleDataArray removeAllObjects];
    [MonthlyScheduleDataArray addObjectsFromArray:monthlyDataArray];
    
    [self saveScheduleDataToFileWithArray:MonthlyScheduleDataArray];
}

- (NSString *)CalendarString:(NSString *)dataFromNTUT
{
    NSString *data = dataFromNTUT;
    NSString *htmlCourseData = @"";
    NSString *startIndex = @"<td height=\"92\" valign=\"top\" bgcolor=\"#FFFF00\"><p>";
    NSString *endIndex = @"<td height=\"27\" colspan=\"10\" align=\"left\" valign=\"middle\" bgcolor=\"#000000\" class=\"style2\">";
    NSRange range = [data rangeOfString:startIndex];
    NSInteger startIdx = range.length + range.location;
    range = [data rangeOfString:endIndex];
    NSInteger endIdx = range.location;
    htmlCourseData = [[data substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
    
    //NSLog(@"%@", htmlCourseData);
    
    return htmlCourseData;
}

- (NSArray *)dataToArrayWithDataString:(NSString *)data inMonth:(int)month
{
    NSMutableArray *date = [[NSMutableArray alloc]init];
    NSMutableArray *events = [[NSMutableArray alloc]init];
    
    [date removeAllObjects];
    [events removeAllObjects];
    
    NSString *contentData = data;
    NSString *eventString = @"";
    switch (month) {
        case 8:
        {
            contentData = [contentData stringByAppendingString:@"<br/>"];
            do{
                NSString *startIndex = @"(";
                NSString *endIndex = @"<br/>";
                NSRange range = [contentData rangeOfString:startIndex];
                NSInteger startIdx = range.length + range.location;
                range = [contentData rangeOfString:endIndex];
                NSInteger endIdx = range.location;
                eventString = [[contentData substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
                NSArray* items = [eventString componentsSeparatedByString:@")"];
                //NSLog(@"date: %@", [items objectAtIndex:0]);
                //NSLog(@"event: %@", [items objectAtIndex:1]);
                [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                [events addObject:[items objectAtIndex:1]];
                contentData = [contentData substringFromIndex:(endIdx + range.length)];
                
            }while ([contentData length] != 0);
            //NSLog(@"contentData length: %lu", (unsigned long)[contentData length]);
        }
            break;
        case 9:
        {
            contentData = [contentData stringByAppendingString:@"、("];
            contentData = [contentData stringByReplacingOccurrencesOfString:@"、(" withString:@"<dayEND>("];
            //NSLog(@"contentData: %@", contentData);
            
            do{
                NSString *startIndex = @"(";
                NSString *endIndex = @"<dayEND>";
                NSRange range = [contentData rangeOfString:startIndex];
                NSInteger startIdx = range.length + range.location;
                range = [contentData rangeOfString:endIndex];
                NSInteger endIdx = range.location;
                eventString = [[contentData substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
                if ([eventString rangeOfString:@"、"].location != NSNotFound) {
                    if ([[eventString substringToIndex:4]isEqual:@"9/12"]) {
                        eventString = [eventString substringFromIndex:5];
                        eventString = [eventString stringByReplacingOccurrencesOfString:@"(碩、博生)" withString:@"???"];
                        NSArray* eventsSub = [eventString componentsSeparatedByString:@"、"];
                        for (int i = 0; i < [eventsSub count]; i++) {
                            NSString *temp = [[eventsSub objectAtIndex:i] stringByReplacingOccurrencesOfString:@"???" withString:@"(碩、博生)"];
                            //                            NSLog(@"date: 9/12");
                            //                            NSLog(@"event: %@", temp);
                            [date addObject:@"9/12"];
                            [events addObject:temp];
                        }
                    }else{
                        NSArray* items = [eventString componentsSeparatedByString:@")"];
                        NSArray* eventsSub = [[items objectAtIndex:1] componentsSeparatedByString:@"、"];
                        for (int i = 0; i < [eventsSub count]; i++) {
                            //                            NSLog(@"date: %@", [[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]);
                            //                            NSLog(@"event: %@", [eventsSub objectAtIndex:i]);
                            [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                            [events addObject:[eventsSub objectAtIndex:i]];
                        }
                    }
                }else{
                    NSArray* items = [eventString componentsSeparatedByString:@")"];
                    //                    NSLog(@"date: %@", [[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]);
                    //                    NSLog(@"event: %@", [items objectAtIndex:1]);
                    [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                    if ([[items objectAtIndex:1] rangeOfString:@"放假一天"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(頒獎"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(學生"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(專題演講"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(暫訂"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else{
                        //NSLog(@"event: %@", [items objectAtIndex:1]);
                        [events addObject:[items objectAtIndex:1]];
                    }
                }
                contentData = [contentData substringFromIndex:(endIdx + range.length)];
            }while ([contentData length] > 1);
            //NSLog(@"contentData length: %lu", (unsigned long)[contentData length]);
            
        }
            break;
        case 10:
        {
            contentData = [contentData stringByAppendingString:@"、("];
            contentData = [contentData stringByReplacingOccurrencesOfString:@"、(" withString:@"<dayEND>("];
            contentData = [contentData stringByReplacingOccurrencesOfString:@"<br/>(" withString:@"<dayEND>("];
            //NSLog(@"contentData: %@", contentData);
            
            do{
                NSString *startIndex = @"(";
                NSString *endIndex = @"<dayEND>";
                NSRange range = [contentData rangeOfString:startIndex];
                NSInteger startIdx = range.length + range.location;
                range = [contentData rangeOfString:endIndex];
                NSInteger endIdx = range.location;
                eventString = [[contentData substringFromIndex:startIdx]substringToIndex:(endIdx - startIdx)];
                if ([eventString rangeOfString:@"、"].location != NSNotFound) {
                    if ([[eventString substringToIndex:5]isEqual:@"10/14"]) {
                        NSArray* items = [eventString componentsSeparatedByString:@")"];
                        //                        NSLog(@"date: %@", [[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]);
                        //                        NSLog(@"event: %@", [items objectAtIndex:1]);
                        [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                        [events addObject:[items objectAtIndex:1]];
                    }else if ([[eventString substringToIndex:5]isEqual:@"11/1)"]) {
                        eventString = [eventString substringFromIndex:5];
                        eventString = [eventString stringByReplacingOccurrencesOfString:@"(慶祝大會及校慶園遊會)" withString:@"???"];
                        NSArray* eventsSub = [eventString componentsSeparatedByString:@"、"];
                        for (int i = 0; i < [eventsSub count]; i++) {
                            NSString *temp = [[eventsSub objectAtIndex:i] stringByReplacingOccurrencesOfString:@"???" withString:@"(慶祝大會及校慶園遊會)"];
                            //                            NSLog(@"date: 11/1");
                            //                            NSLog(@"event: %@", temp);
                            [date addObject:@"11/1"];
                            [events addObject:temp];
                        }
                    }else if ([[eventString substringToIndex:4]isEqual:@"2/24"]) {
                        eventString = [eventString substringFromIndex:5];
                        eventString = [eventString stringByReplacingOccurrencesOfString:@"(暫定)" withString:@"???"];
                        NSArray* eventsSub = [eventString componentsSeparatedByString:@"、"];
                        for (int i = 0; i < [eventsSub count]; i++) {
                            NSString *temp = [[eventsSub objectAtIndex:i] stringByReplacingOccurrencesOfString:@"???" withString:@"(暫定)"];
                            //                            NSLog(@"date: 2/24");
                            //                            NSLog(@"event: %@", temp);
                            [date addObject:@"2/24"];
                            [events addObject:temp];
                        }
                    }else{
                        NSArray* items = [eventString componentsSeparatedByString:@")"];
                        NSArray* eventsSub = [[items objectAtIndex:1] componentsSeparatedByString:@"、"];
                        for (int i = 0; i < [eventsSub count]; i++) {
                            //                            NSLog(@"date: %@", [[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]);
                            //                            NSLog(@"event: %@", [eventsSub objectAtIndex:i]);
                            [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                            [events addObject:[eventsSub objectAtIndex:i]];
                        }
                    }
                }else{
                    NSArray* items = [eventString componentsSeparatedByString:@")"];
                    //                    NSLog(@"date: %@", [[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]);
                    [date addObject:[[items objectAtIndex:0]stringByReplacingOccurrencesOfString:@"~" withString:@"-"]];
                    
                    if ([[items objectAtIndex:1] rangeOfString:@"放假一天"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(頒獎"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(學生"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(專題演講"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else if ([[items objectAtIndex:1] rangeOfString:@"(暫訂"].location != NSNotFound) {
                        NSString *tmp = [[items objectAtIndex:1]stringByAppendingString:@")"];
                        //NSLog(@"event: %@", tmp);
                        [events addObject:tmp];
                    }else{
                        //NSLog(@"event: %@", [items objectAtIndex:1]);
                        [events addObject:[items objectAtIndex:1]];
                    }
                }
                contentData = [contentData substringFromIndex:(endIdx + range.length)];
            }while ([contentData length] > 1);
            //NSLog(@"contentData length: %lu", (unsigned long)[contentData length]);
        }
            break;
        default:
            break;
    }
    
    NSArray *monthData = [[NSArray alloc] initWithObjects:date,events, nil];
    
    return monthData;
}

#pragma mark - Save/Retrieve Function

- (void)saveScheduleDataToFileWithArray:(NSArray *)monthlyArray {
    //File Path
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [path objectAtIndex:0];
    NSString *filePath = [documentFolder stringByAppendingFormat:@"/schoolSchedule.plist"];
    
    //Save Data
    [monthlyArray writeToFile:filePath atomically:YES];
}

@end
