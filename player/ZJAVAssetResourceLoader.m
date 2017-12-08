//
//  ZJAVAssetResourceLoader.m
//  player
//
//  Created by 郜泽建 on 2017/12/7.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJAVAssetResourceLoader.h"
@interface ZJAVAssetResourceLoader ()
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@end
@implementation ZJAVAssetResourceLoader

-(instancetype)init{
    if (self = [super init]) {
    
    }
    return self;
}
#pragma mark AVAssetResourceLoader代理方法
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"resourceLoader");
     [self.pendingRequests addObject:loadingRequest];
    [self dealWithLoadingRequest:loadingRequest];
//    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:loadingRequest.request.URL resolvingAgainstBaseURL:NO];
//    urlComponents.scheme = @"http";
//    NSMutableURLRequest *mutableLoadingRequest = [loadingRequest.request mutableCopy];
//    [mutableLoadingRequest setURL:urlComponents.URL];
    return YES;
}
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, 100);//NSUIntegerMax
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests removeObject:loadingRequest];
    
}
@end
