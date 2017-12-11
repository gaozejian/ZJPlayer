//
//  ZJAVAssetResourceLoader.m
//  player
//
//  Created by 郜泽建 on 2017/12/7.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJAVAssetResourceLoader.h"
@interface ZJAVAssetResourceLoader ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSMutableArray *pendingRequests;
/*注释:<#name#> */
@property (nonatomic, strong) NSURLSessionDownloadTask * task;
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
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, 10000);//NSUIntegerMax
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:components.URL];
   
    [request setValue:[NSString stringWithFormat:@"bytes=%ld-%ld",range.location,range.length] forHTTPHeaderField:@"Range"];
    NSLog(@"allHTTPHeaderFields==%@",request.allHTTPHeaderFields);
    [self createSession:request];
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests removeObject:loadingRequest];
    
}

-(void)createSession:(NSMutableURLRequest*)request{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
  
   self.task = [session downloadTaskWithRequest:request];
    [self.task resume];
}
// 每次写入调用(会调用多次)
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    // 可在这里通过已写入的长度和总长度算出下载进度
    CGFloat progress = 1.0 * totalBytesWritten / totalBytesExpectedToWrite; 
    NSLog(@"progress======%f",progress);
}

// 下载完成调用
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    // location还是一个临时路径,需要自己挪到需要的路径(caches下面)
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSLog(@"filePath=======%@",filePath);
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
}

// 任务完成调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
}

@end
