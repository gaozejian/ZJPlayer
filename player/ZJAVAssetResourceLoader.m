//
//  ZJAVAssetResourceLoader.m
//  player
//
//  Created by 郜泽建 on 2017/12/7.
//  Copyright © 2017年 郜泽建. All rights reserved.
//

#import "ZJAVAssetResourceLoader.h"
#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface ZJAVAssetResourceLoader ()<NSURLSessionDataDelegate>
@property (nonatomic, strong) NSMutableArray *pendingRequests;
/*注释:<#name#> */
@property (nonatomic, strong) NSURLSessionDataTask * task;
/*注释:<#name#> */
@property (nonatomic, strong) AVAssetResourceLoadingRequest *LoadingRequest;
/*注释:<#name#> */
@property (nonatomic, strong) NSMutableData *downData;
/*注释:<#name#> */
@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) NSFileHandle    *fileHandle;
@end
@implementation ZJAVAssetResourceLoader

-(instancetype)init{
    if (self = [super init]) {
        self.pendingRequests = [[NSMutableArray alloc]init];
        self.downData = [[NSMutableData alloc]init];
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.videoPath = [document stringByAppendingPathComponent:@"temp.mp3"];
        [[NSFileManager defaultManager] createFileAtPath:self.videoPath contents:nil attributes:nil];
         self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.videoPath];
        
    }
    return self;
}
#pragma mark AVAssetResourceLoader代理方法
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"resourceLoader");
    if(![self.pendingRequests containsObject:loadingRequest]){
     [self.pendingRequests addObject:loadingRequest];
    }
       self.LoadingRequest = loadingRequest;
    [self dealWithLoadingRequest:loadingRequest];

    return YES;
}
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.currentOffset, (NSUInteger)loadingRequest.dataRequest.requestedLength);//NSUIntegerMax
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:components.URL];
    if(range.length  > 2){
    [request setValue:[NSString stringWithFormat:@"bytes=%ld-%ld",range.location,range.length] forHTTPHeaderField:@"Range"];
    }
    NSLog(@"allHTTPHeaderFields==%@",request.allHTTPHeaderFields);
   
    [self createSession:request];
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
   // [self.pendingRequests removeObject:loadingRequest];
    
}

-(void)createSession:(NSMutableURLRequest*)request{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
  
  // self.task = [session downloadTaskWithRequest:request];
     self.task = [session dataTaskWithRequest:request];
    [self.task resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [self.downData appendData:data];
//    [self.fileHandle seekToEndOfFile];
//    [self.fileHandle writeData:data];
//

 dispatch_async(dispatch_get_main_queue(), ^{

    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
    for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
       // NSString *mimeType = @"com.apple.m4a-audio";
        ResourceLoadingRequest.contentInformationRequest.contentType = dataTask.response.MIMEType;
        ResourceLoadingRequest.contentInformationRequest.contentLength =  dataTask.response.expectedContentLength;
        ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = NO;

        
        CGFloat startOffset = ResourceLoadingRequest.dataRequest.requestedOffset;
        CGFloat requestedLength = ResourceLoadingRequest.dataRequest.requestedLength;
      
        if (ResourceLoadingRequest.dataRequest.currentOffset != 0) {
            startOffset = ResourceLoadingRequest.dataRequest.currentOffset;
        }
        
        NSUInteger unreadBytes = self.downData.length - ((NSInteger)startOffset - 0);
        NSLog(@"requestedLength===%ld =length== %lu",ResourceLoadingRequest.dataRequest.requestedLength,(unsigned long)data.length);

        NSUInteger numberOfBytesToRespondWith =unreadBytes;
        
     //   [ResourceLoadingRequest.dataRequest respondWithData:[self.downData subdataWithRange:NSMakeRange((NSUInteger)startOffset- 0, (NSUInteger)numberOfBytesToRespondWith)]];
      //  [ResourceLoadingRequest finishLoading];
       [ResourceLoadingRequest.dataRequest respondWithData:data];
     //     NSLog(@"====%@ =\nstartOffset= %f  \n-====currentOffset====%lld=",ResourceLoadingRequest.contentInformationRequest,startOffset,ResourceLoadingRequest.dataRequest.currentOffset);
       [ResourceLoadingRequest finishLoading];
    }

 });

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
  for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
       [ResourceLoadingRequest finishLoading];
  }
    NSLog(@"下载结束");

  
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream * _Nullable))completionHandler{
    
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
    
    //  [self.delegate downLoading:filePath];
}


-(void)cancelTask{
    [self.task cancel];
}
@end
