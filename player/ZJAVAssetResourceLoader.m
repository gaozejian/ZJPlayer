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

///*注释:<#name#> */
@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) NSFileHandle    *fileHandle;


@end
@implementation ZJAVAssetResourceLoader
static CGFloat startOffset = 0;
static NSInteger rangeCount = 0;
static long long totalLength = 0;
-(instancetype)init{
    if (self = [super init]) {
        self.pendingRequests = [NSMutableArray array];
         self.complementRequests = [NSMutableArray array];

        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        self.videoPath = [document stringByAppendingPathComponent:@"temp.mp3"];
        [[NSFileManager defaultManager] createFileAtPath:self.videoPath contents:nil attributes:nil];
         self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.videoPath];
        
    }
    return self;
}
#pragma mark AVAssetResourceLoader代理方法
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"开始==currentOffset%lld",loadingRequest.dataRequest.currentOffset);
 //   [self.pendingRequests removeAllObjects];
         [self.pendingRequests addObject:loadingRequest];

        self.LoadingRequest = loadingRequest;
        [self dealWithLoadingRequest:loadingRequest];
  
    return YES;
}
- (void)dealWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"===============重新请求================");
     NSData *filedata1 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
    NSURL *interceptedURL = [loadingRequest.request URL];
    NSRange range = NSMakeRange((NSUInteger)loadingRequest.dataRequest.requestedOffset, (NSUInteger)loadingRequest.dataRequest.requestedLength);//
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:components.URL];

        NSLog(@"rangeCount========%ld ===total %lld",rangeCount ,totalLength);
[request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",range.location,range.length] forHTTPHeaderField:@"Range"];
//    if (range.length < 5) {
//        [request addValue:[NSString stringWithFormat:@"bytes=%ld-%ld",range.location,range.length] forHTTPHeaderField:@"Range"];
//    }else{
//        //55108420
//    [request addValue:[NSString stringWithFormat:@"bytes=%ld-%lld",filedata1.length - 1,totalLength - filedata1.length] forHTTPHeaderField:@"Range"];
//    }
    
    NSLog(@"allHTTPHeaderFields===%@",request.allHTTPHeaderFields);
   
    [self createSession:request];
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest

{NSLog(@"======================currentOffset====断了=%lld",loadingRequest.dataRequest.currentOffset);
    NSLog(@"==================requestedLength========断了=%ld",loadingRequest.dataRequest.requestedLength);
    NSLog(@"===================requestedOffset========%lld",loadingRequest.dataRequest.requestedOffset);
 NSLog(@"===================chazhi=======断了=%lld",loadingRequest.dataRequest.currentOffset -loadingRequest.dataRequest.requestedLength);
    [self.task cancel];
    self.task = nil;
    for (AVAssetResourceLoadingRequest * load in self.pendingRequests) {
        [load finishLoading];
    }
    [self.pendingRequests removeAllObjects];
   
}

-(void)createSession:(NSMutableURLRequest*)request{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:self
                                                     delegateQueue:[[NSOperationQueue alloc] init]];
  
 
     self.task = [session dataTaskWithRequest:request];
    [self.task resume];
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
 
    // 允许处理服务器的响应，才会继续接收服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
}


-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    


    
                
                for (AVAssetResourceLoadingRequest * ResourceLoadingRequest  in self.pendingRequests) {
                    
                    NSData *filedata1 = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];

                   
                  //  NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
                    NSHTTPURLResponse * re = (NSHTTPURLResponse*)dataTask.response;
                    
                    NSString * length = re.allHeaderFields[@"Content-Range"];
                    
                    
                    ResourceLoadingRequest.contentInformationRequest.contentType = dataTask.response.MIMEType;
                    ResourceLoadingRequest.contentInformationRequest.contentLength =  [[length componentsSeparatedByString:@"/"][1] integerValue];
                    static dispatch_once_t onceToken;
                    dispatch_once(&onceToken, ^{
                     totalLength = ResourceLoadingRequest.contentInformationRequest.contentLength;
                    });
                    
                    ResourceLoadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
                    
                    CGFloat requestedOffset = ResourceLoadingRequest.dataRequest.requestedOffset;
                    CGFloat currentOffset =  ResourceLoadingRequest.dataRequest.currentOffset;
                    
                    if(currentOffset >= requestedOffset){
                        startOffset = currentOffset ;
                    }else{
                        startOffset = requestedOffset;
                    }
                    if (startOffset  < filedata1.length ) {
                        NSLog(@"比我小====startOffset=%f   =%ld filedata.length=%ld  data.length= %ld",startOffset,filedata1.length - data.length,filedata1.length,data.length);
                     //   startOffset = filedata.length - data.length;
                        [self.fileHandle seekToFileOffset:startOffset];
                        [self.fileHandle writeData:data];
                    }else{
                        [self.fileHandle seekToEndOfFile];
                        [self.fileHandle writeData:data];
                    }
                    NSData *filedata = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath] options:NSDataReadingMappedIfSafe error:nil];
                    NSUInteger unreadBytes = filedata.length - ((NSInteger)startOffset);
                    
                    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)ResourceLoadingRequest.dataRequest.requestedLength, unreadBytes) ;
                
                      if(dataTask.state == NSURLSessionTaskStateRunning){
                    NSRange  range = NSMakeRange(startOffset, numberOfBytesToRespondWith);
                    NSLog(@"==%f  length = %ld,current==%f xount= %ld=%@",requestedOffset,ResourceLoadingRequest.dataRequest.requestedLength,currentOffset,rangeCount,NSStringFromRange(range));
                    
                    rangeCount = range.location + range.length ;
                    NSData *  rangedata =[filedata subdataWithRange:range];
                  
                    [ResourceLoadingRequest.dataRequest respondWithData:rangedata];
                    }
                    NSLog(@"currentOffset=====%lld---%ld",ResourceLoadingRequest.dataRequest.currentOffset,filedata.length);
                    if((ResourceLoadingRequest.dataRequest.requestedOffset + ResourceLoadingRequest.dataRequest.requestedLength <=filedata.length) &&filedata.length <totalLength ){
                        [dataTask cancel];
                        [ResourceLoadingRequest finishLoading];
                        [self.complementRequests addObject:ResourceLoadingRequest];
                        [self.pendingRequests removeObjectsInArray:self.complementRequests];
                        
                        
                        NSLog(@"========================移除");
                        
                        return;
                    }
                    if(filedata.length >= totalLength){
                          [self.task cancel];
                        self.task = nil;
                        return ;
                    }
                }
                

}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{

  


    NSLog(@"下载结束 %@",self.videoPath);

  
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"网络失败===========%@",error.description);
}

-(void)cancelTask{
    [self.task cancel];
}
@end
