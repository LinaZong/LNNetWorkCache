//
//  LNAFNetWork.m
//  LNNetWorkCache
//
//  Created by 宗丽娜 on 16/10/19.
//  Copyright © 2016年 宗丽娜. All rights reserved.
//

#import "LNAFNetWork.h"

@implementation LNAFNetWork
static BOOL _isNetwork;
static AFHTTPSessionManager *_manager;

#pragma mark-初始化单例
+(void)initialize{
    _manager = [AFHTTPSessionManager manager];
    
    //设置请求可以接受的数据类型
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    
    //设置请求的超时时间
    _manager.requestSerializer.timeoutInterval = 30.f;
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //打开状态栏的等待菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
}
#pragma mark - 网络监听
+(void)networkStatusWithBlock:(NetworkStatus)networkStatus{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken ,^{
        
        AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    networkStatus ? networkStatus(LNNetWorkStatusUnknown) : nil;
            
                    NSLog(@"未知网络");
                    break;
                    
                    
                case AFNetworkReachabilityStatusNotReachable:
                    networkStatus ? networkStatus(LNNetWorkStatusNotReachable) : nil;
                  
                    NSLog(@"无网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    networkStatus ? networkStatus(LNNetWorkStatusReachableWWAN) : nil;
                  
                   NSLog(@"手机自带网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    networkStatus ? networkStatus(LNNetWorkStatusReachableWIFi) : nil;
                   
                    NSLog(@"WIFI");
                    break;
                default:
                    break;
            }
        }];
        [manager startMonitoring];
    });
}




#pragma mark - GET请求
+(NSURLSessionTask *)GET:(NSString *)URL Parameters:(NSDictionary *)parameters IsCache:(BOOL) isCache ResponseCache:(HttpRequestCache)responseCache success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure{
    
    if(!isCache){
       
        responseCache = nil;

    }
    
    //先从缓存中取，如果有则取缓存，如果没有则为nil
    if (responseCache) {
        responseCache([LNNetWorkCache httpCacheForURL:URL parameters:parameters]);
    }else{
        responseCache = nil;
    }
    return [_manager GET:URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
        //成功之后对数据进行缓存
        if (responseCache) {
            [LNNetWorkCache setHttpCache:responseObject URL:URL Parameters:parameters];
            NSLog(@"缓存成功");
        }
     
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"error=%@",error);
        }
    }];
    
}

#pragma mark - POST请求
+(NSURLSessionTask *)POST:(NSString *)URL Parameters:(NSDictionary *)parameters IsCache:(BOOL) isCache ResponseCache:(HttpRequestCache)responseCache success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure{
    if(!isCache){
        
        responseCache = nil;
    }
    
    //如果需要缓存，先读取缓存
    responseCache ? responseCache([LNNetWorkCache httpCacheForURL:URL parameters:parameters]) : nil;
    return [_manager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        if (success) {
            success(responseObject);
        }
        //对数据进行异步缓存
        responseCache ? ([LNNetWorkCache setHttpCache:responseObject URL:URL Parameters:parameters]) : nil;
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        if (failure) {
            
            failure(error);
            
            NSLog(@"数据请求失败");
        }else{
            failure(nil);
        }
    
    }];
    
}

#pragma mark - 检查是否有缓存

+(id)isExistCacheWithURL:(NSString *)URL Parameters:(NSDictionary *)parameters{

    return  [LNNetWorkCache httpCacheForURL:URL parameters:parameters];
    
}



//上传图片文件
+(NSURLSessionTask *)UploadWithURL:(NSString *)URL Parameters:(NSDictionary *)parameters Images:(NSArray<UIImage *> *)images Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Progress:(HttpProgress)progress Success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure{
    
    return [_manager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //图片经过压缩-添加-上传
        
        //循环数组
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData * imageData = UIImageJPEGRepresentation(obj, 0.5);
            
[formData appendPartWithFileData:imageData name:name fileName:[NSString stringWithFormat:@"%@%lu.%@",fileName,(unsigned long)idx,mimeType?mimeType:@"jpeg"] mimeType:[NSString stringWithFormat:@"image/%@",mimeType ? mimeType : @"jpeg"]];
            
        }];
        
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(uploadProgress);
            
            }
            
        });
       
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
            NSLog(@"上传成功");
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"错误提示=%@",error);
        }
       
    }];
}


#pragma mark - 下载文件
+(NSURLSessionTask *)DownLoadWithURL:(NSString *)URL FileDir:(NSString *)fileDir Progress:(HttpProgress)progress Success:(void(^)(NSString * filePath)) success Failure:(HttpRequestFailed)failure{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    NSURLSessionDownloadTask * downLoadTask = [_manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            if (progress) {
                progress(downloadProgress);
            }
        });
           NSLog(@"下载进度:%.2f%%",100.0*downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
       
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString * saveFile = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileDir? fileDir:@"Dowmload"];
        //打开文件管理器
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        //创建Download目录
        [fileManager createDirectoryAtPath:saveFile withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString * filePath = [saveFile stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"saveFile = %@",saveFile);
        
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if(failure && error) {failure(error) ; return ;};
        success ? success(filePath.absoluteString ) : nil;
    }];
    
    [downLoadTask resume];
    
    
    return  downLoadTask;
}


#pragma mark - 重置AFHTTPSessionManager相关属性
+ (void)setRequestSerializer:(PPRequestSerializer)requestSerializer
{
    _manager.requestSerializer = requestSerializer==PPRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
}

+ (void)setResponseSerializer:(PPResponseSerializer)responseSerializer
{
    _manager.responseSerializer = responseSerializer==PPResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    _manager.requestSerializer.timeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_manager.requestSerializer setValue:value forHTTPHeaderField:field];
}

+ (void)openNetworkActivityIndicator:(BOOL)open
{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:open];
}
@end
