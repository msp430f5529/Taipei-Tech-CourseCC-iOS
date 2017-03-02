//
//  HttpPost.h
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/3.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSURLConnection;
@protocol HttpPostDelegate;

@interface HttpPost : NSObject

- (HttpPost *) initWithURL:(NSURL *)fileURL
            postData:(NSString *)postContent
              cookie:(NSString *)cookie
             timeout:(NSInteger)timeout
            delegate:(id<HttpPostDelegate>)theDelegate;

@property (nonatomic, readonly) NSMutableData* receivedData;
@property (nonatomic, readonly, retain) NSMutableURLRequest* downloadRequest;
@property (nonatomic, readonly, retain) NSURLConnection* downloadConnection;
@property (nonatomic, assign) id<HttpPostDelegate> delegate;

- (void) startDownloadWithURL:(NSURL *)_url postData:(NSString *)postContent cookie:(NSString *)cookieValue;
@end

@protocol HttpPostDelegate <NSObject>

@optional
- (void) httpPost:(HttpPost *)httpPost didReceiveResponseWithCookie:(NSString *)responseCookie;
- (void) httpPost:(HttpPost *)httpPost didFinishWithData:(NSData *)fileData;
- (void) httpPost:(HttpPost *)httpPost didFailWithError:(NSError *)error;

@end
