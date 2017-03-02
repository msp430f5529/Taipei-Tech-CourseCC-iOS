//
//  DrawMealViewController.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/10/20.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HttpPost.h"

@interface DrawMealViewController : UIViewController <HttpPostDelegate>
{
    IBOutlet UIImageView *imgView;
    IBOutlet UILabel *restaurantLabel;
    IBOutlet UIImageView *restaurantImg;
    IBOutlet UILabel *addressLabel;
    IBOutlet UIImageView *addressImg;
    IBOutlet UILabel *telLabel;
    IBOutlet UIImageView *telImg;
    IBOutlet UILabel *priceLabel;
    IBOutlet UIImageView *priceImg;
    
}
@property (nonatomic, strong) NSString *selectionType;
@property (nonatomic, strong) NSString *selectionPlace;
@property (nonatomic, strong) NSString *selectionPrice;

@end
