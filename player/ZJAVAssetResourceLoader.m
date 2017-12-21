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
@property (nonatomic, strong) NSMutableArray *complementRequests;
/*注释:<#name#> */
@property (nonatomic, strong) NSURLSessionDataTask * task;
/*注释:<#name#> */
@property (nonatomic, strong) AVAssetResourceLoadingRequest *LoadingRequest;
/*注释:<#name#> */
@property (nonatomic, strong) NSMutableData *downData;
///*注释:<#name#> */
@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) NSFileHandle    *fileHandle;
@end
@implementation ZJAVAssetResourceLoader
static CGFloat startOffset = 0;
static CGFloat rangeCount = 0;
-(instancetype)init{
    if (self = [super init]) {
        self.pendingRequests = [NSMutableArray array];
         self.complementRequests = [NSMutableArray array];
        
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
 
    [self.pendingRequests removeAllObjects];
         [self.pendingRequests addObject:loadingRequest];

        self.LoadingRequest = loadingRequest;
        [self dealWithLoadingRequest:loadingRequest];
  
    return YES;
}
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"===============重新请求================");

    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.requestedOffset, (NSUInteger)loadingRequest.dataRequest.requestedLength);//
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:components.URL];
//[request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",range.location,range.length] forHTTPHeaderField:@"Range"];
 // request.allHTTPHeaderFields =
   
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
  
 
     self.task = [session dataTaskWithRequest:request];
    [self.task resume];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
        
        ResourceLoadingRequest.contentInformationRequest.contentType = response.MIMEType;
        ResourceLoadingRequest.contentInformationRequest.contentLength =  response.expectedContentLength;
ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
    }
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    


 dispatch_async(dispatch_get_main_queue(), ^{
 
     [self.fileHandle seekToEndOfFile];
     [self.fileHandle writeData:data];
      NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
    for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {

        ResourceLoadingRequest.contentInformationRequest.contentType = dataTask.response.MIMEType;
        ResourceLoadingRequest.contentInformationRequest.contentLength =  dataTask.response.expectedContentLength;
  ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
        CGFloat requestedOffset = ResourceLoadingRequest.dataRequest.requestedOffset;
      CGFloat currentOffset =  ResourceLoadingRequest.dataRequest.currentOffset;
        if (currentOffset != 0) {
            startOffset = currentOffset ;
        }else{
            startOffset = requestedOffset;
        }

         NSUInteger unreadBytes = filedata.length - ((NSInteger)startOffset);
       //   NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)ResourceLoadingRequest.dataRequest.requestedLength, unreadBytes);
        NSUInteger numberOfBytesToRespondWith ;
        if ((NSUInteger)ResourceLoadingRequest.dataRequest.requestedLength  < unreadBytes) {
            numberOfBytesToRespondWith = (NSUInteger)ResourceLoadingRequest.dataRequest.requestedLength;
            NSLog(@"requestedLength");
        }else{
            numberOfBytesToRespondWith = unreadBytes;
            NSLog(@"unreadBytes");
        }
 
           NSRange  range = NSMakeRange(startOffset, numberOfBytesToRespondWith);
 NSLog(@"==%f current==%f xount= %f=%@",requestedOffset,currentOffset,rangeCount,NSStringFromRange(range));
        if (rangeCount != range.location) {
            NSLog(@"=============不一样===============");
       
        }
        rangeCount = range.location + range.length;
       NSData *  rangedata =[filedata subdataWithRange:range];
     [ResourceLoadingRequest.dataRequest respondWithData:rangedata];
     

        if(ResourceLoadingRequest.dataRequest.requestedOffset + ResourceLoadingRequest.dataRequest.requestedLength <=filedata.length  ){
               [ResourceLoadingRequest finishLoading];
            [self.complementRequests addObject:ResourceLoadingRequest];
     
        }
    }
     [self.pendingRequests removeObjectsInArray:self.complementRequests];
 });

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
//  for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
//      [ResourceLoadingRequest finishLoading];
//  }
    
    NSLog(@"下载结束 %@",self.videoPath);

  
}



-(void)cancelTask{
    [self.task cancel];
}
@end
