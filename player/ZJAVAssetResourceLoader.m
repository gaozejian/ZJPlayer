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
     NSLog(@" 当前线程  %@",[NSThread currentThread]);
    NSLog(@"delegate===requestedLength=%ld ==requestedOffset=%lld ==currentOffset=%lld",loadingRequest.dataRequest.requestedLength,loadingRequest.dataRequest.requestedOffset,loadingRequest.dataRequest.currentOffset);
       // if(![self.pendingRequests containsObject:loadingRequest]){
         [self.pendingRequests addObject:loadingRequest];
      //  }
        self.LoadingRequest = loadingRequest;
        [self dealWithLoadingRequest:loadingRequest];
  
    return YES;
}
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@" 当前线程  %@",[NSThread currentThread]);
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.requestedOffset, (NSUInteger)loadingRequest.dataRequest.requestedLength);//
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:components.URL];

  
   
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
 // response.
       NSLog(@"=====%@",response.MIMEType);
        ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
    }
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    


 dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@" 当前线程  %@",[NSThread currentThread]);
    
     [self.downData appendData:data];
     [self.fileHandle seekToEndOfFile];
     [self.fileHandle writeData:data];
    for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {

        ResourceLoadingRequest.contentInformationRequest.contentType = dataTask.response.MIMEType;
        ResourceLoadingRequest.contentInformationRequest.contentLength =  dataTask.response.expectedContentLength;
        NSLog(@"=====%@",dataTask.response.MIMEType);
        ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
            
    
         startOffset = ResourceLoadingRequest.dataRequest.requestedOffset;
        if (ResourceLoadingRequest.dataRequest.currentOffset != 0) {
            startOffset =ResourceLoadingRequest.dataRequest.currentOffset;
        }
        CGFloat requestedLength = ResourceLoadingRequest.dataRequest.requestedLength;
      
     
        NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
        
         NSUInteger unreadBytes = self.downData.length - ((NSInteger)startOffset);
          NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)ResourceLoadingRequest.dataRequest.requestedLength, unreadBytes);
        NSData * rangedata;
        if (startOffset + numberOfBytesToRespondWith > filedata.length) {
             rangedata =[filedata subdataWithRange:NSMakeRange(startOffset, filedata.length - startOffset)];
        }else{
             rangedata =[filedata subdataWithRange:NSMakeRange(startOffset, numberOfBytesToRespondWith)];
        }
       
     [ResourceLoadingRequest.dataRequest respondWithData:rangedata];
     
        NSLog(@"===requestedLength=%ld %f=\nstartOffset= %f  \n-====currentOffset====%lld=   self.downData.length== %ld",ResourceLoadingRequest.dataRequest.requestedLength,requestedLength,startOffset,ResourceLoadingRequest.dataRequest.currentOffset,self.downData.length);
      
    
        if(startOffset + requestedLength <=self.downData.length){
               [ResourceLoadingRequest finishLoading];
            [self.complementRequests addObject:ResourceLoadingRequest];
     
        }
    }
     [self.pendingRequests removeObjectsInArray:self.complementRequests];
 });

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
  for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
      [ResourceLoadingRequest finishLoading];
  }
    
    NSLog(@"下载结束 %@",self.videoPath);

  
}



-(void)cancelTask{
    [self.task cancel];
}
@end
