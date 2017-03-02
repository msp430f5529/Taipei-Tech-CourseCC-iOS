//
//  HttpPost.m
//  CourseCC
//
//  Created by Luther Tsai on 2015/5/3.
//  Copyright (c) 2015年 Luther Tsai. All rights reserved.
//

#import "HttpPost.h"

@interface HttpPost () {
    NSString			*localFilename;
    NSURL				*postURL;
    NSString            *_postContent;
    NSString            *_cookies;
    BOOL				operationFinished, operationFailed, operationBreaked;
    NSInteger           _timeOut;
}

@end

@implementation HttpPost

- (HttpPost *) initWithURL:(NSURL *)URL
            postData:(NSString *)postContent
              cookie:(NSString *)cookie
             timeout:(NSInteger)timeout
            delegate:(id<HttpPostDelegate>)theDelegate
{
    if(self) {
        self.delegate = theDelegate;
        _timeOut = timeout;
        postURL = URL;
        _postContent = postContent;
        _cookies = cookie;
        _receivedData = [[NSMutableData alloc] initWithLength:0];
    }
    
    return self;
}

- (void) startDownloadWithURL:(NSURL *)_url postData:(NSString *)postContent cookie:(NSString *)cookieValue
{
    postURL = _url;
    _postContent = postContent;
    _cookies = cookieValue;
    _timeOut = 2.9;
    _postContent = [_postContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSData *postData = [_postContent dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    _downloadRequest = [[NSMutableURLRequest alloc] initWithURL:postURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1];
    //指定封包方式
    [_downloadRequest setHTTPMethod:@"POST"];
    if (postLength != 0) {
        [_downloadRequest setHTTPBody:postData];
    }
    //指定HTTP表頭
    [_downloadRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [_downloadRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [_downloadRequest setValue:_cookies forHTTPHeaderField:@"Cookie"];
    [_downloadRequest setValue:@"/" forHTTPHeaderField:@"path"];
    [_downloadRequest setTimeoutInterval:_timeOut];
    
    _downloadConnection = [[NSURLConnection alloc] initWithRequest:_downloadRequest delegate:self startImmediately:YES];

   
    if(_downloadConnection == nil) {
    
    
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Fail");
    if ([self.delegate respondsToSelector:@selector(httpPost:didFailWithError:)]) {
        [self.delegate httpPost:self didFailWithError:error];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        
        if ([dictionary objectForKey:@"Set-Cookie"] != nil)
        {
            NSArray* cookieItems = [[dictionary objectForKey:@"Set-Cookie"] componentsSeparatedByString:@"; "];
            if ([self.delegate respondsToSelector:@selector(httpPost:didReceiveResponseWithCookie:)]) {
                [self.delegate httpPost:self didReceiveResponseWithCookie:[cookieItems objectAtIndex:0]];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(httpPost:didReceiveResponseWithCookie:)]) {
                [self.delegate httpPost:self didReceiveResponseWithCookie:@""];
            }
        }
    }
    [self.receivedData setLength:0];
}


- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(httpPost:didFinishWithData:)]) {
        [self.delegate httpPost:self didFinishWithData:self.receivedData];
    }
}


- (void) dealloc {

}

@end
