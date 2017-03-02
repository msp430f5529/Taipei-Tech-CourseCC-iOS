//
//  DrawMealViewController.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/10/20.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "DrawMealViewController.h"
#import "HttpPost.h"
#include <stdlib.h>

@interface DrawMealViewController ()
{
    HttpPost *client;
    NSMutableDictionary *restaruantDict;
}
@end

@implementation DrawMealViewController
@synthesize selectionPlace, selectionPrice, selectionType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    restaurantLabel.hidden = YES;
    addressLabel.hidden = YES;
    priceLabel.hidden = YES;
    telLabel.hidden = YES;
    restaurantImg.hidden = YES;
    addressImg.hidden = YES;
    priceImg.hidden = YES;
    telImg.hidden = YES;
    
    client = [[HttpPost alloc] init];
    
    NSArray *imageNames = @[@"giphy_1.png", @"giphy_2.png", @"giphy_3.png", @"giphy_4.png",
                            @"giphy_5.png", @"giphy_6.png", @"giphy_7.png", @"giphy_8.png",
                            @"giphy_9.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    imgView.animationImages = images;
    imgView.animationDuration = 1;
    imgView.alpha = 1.0f;
    [imgView startAnimating];
    
    if ([self checkInternet]) {
        [self drawRestaurant];
    }
    else
    {
        [self showErrorWithErrorCode:404];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Draw a Restaurant

- (void) drawRestaurant {
    NSString *URL = @"https://luthertsai.com/ntutFoodCourt/ViewRestaurantAPI.php";
    NSURL *url = [NSURL URLWithString:URL];
    NSString *post = [NSString stringWithFormat:@"Area=%@&Price=%@&Type=%@", selectionPlace,selectionPrice,selectionType];
    client = [[HttpPost alloc] initWithURL:url postData:post cookie:nil timeout:15 delegate:self];
    [client startDownloadWithURL:url postData:post cookie:nil];
}

#pragma mark - HTTP Post Delegate

- (void) httpPost:(HttpPost *)httpPost didFailWithError:(NSError *)error
{
    UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統不穩定"
                                                      message:@"請稍後再試"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [caution show];
}

- (void) httpPost:(HttpPost *)httpPost didReceiveResponseWithCookie:(NSString *)responseCookie
{
}

- (void) httpPost:(HttpPost *)httpPost didFinishWithData:(NSData *)fileData
{
    NSError *errorJson=nil;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:fileData options:kNilOptions error:&errorJson];
    
    if ([[responseDict objectForKey:@"Result-Count"]integerValue] != 0) {
        int r = arc4random_uniform((int)[[responseDict objectForKey:@"Result-Count"]integerValue]);
        restaruantDict = [[NSMutableDictionary alloc] initWithDictionary:[[responseDict objectForKey:@"Restaurants"]objectAtIndex:r] copyItems:YES];
        restaurantLabel.text = [restaruantDict objectForKey:@"r_name"];
        addressLabel.text = [restaruantDict objectForKey:@"r_address"];
        priceLabel.text = [restaruantDict objectForKey:@"r_avg_spend"];
        telLabel.text = [restaruantDict objectForKey:@"r_telphone"];
        
        [self DrawRestaurantDone];
    }
    else
    {
        [self showErrorWithErrorCode:303];
    }
}

-(void)DrawRestaurantDone{
    [imgView stopAnimating];
    imgView.image = [UIImage imageNamed:@"EmptyPlate"];
    imgView.alpha = 0.3f;
    
    restaurantLabel.hidden = NO;
    addressLabel.hidden = NO;
    priceLabel.hidden = NO;
    telLabel.hidden = NO;

    restaurantImg.hidden = NO;
    addressImg.hidden = NO;
    priceImg.hidden = NO;
    telImg.hidden = NO;
}

#pragma mark - Fetching Check

- (BOOL)checkInternet
{
    NSString *connect = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://luthertsai.com"] encoding:NSUTF8StringEncoding error:nil];
    BOOL checkFlag;
    
    if (connect == NULL) {
        checkFlag = FALSE;
    }
    else {
        checkFlag = TRUE;
    }
    return checkFlag;
}

#pragma mark - Error Function

- (void) showErrorWithErrorCode:(int)errCode
{
    switch (errCode) {
        case 303:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"範圍內沒有餐廳"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        case 404:
        {
            UIAlertView *caution = [[UIAlertView alloc] initWithTitle:@"系統錯誤"
                                                              message:@"請檢查網路設定"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [caution show];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Status Bar Style
//change status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
