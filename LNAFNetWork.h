//
//  LNAFNetWork.h
//  LNNetWorkCache
//
//  Created by 宗丽娜 on 16/10/19.
//  Copyright © 2016年 宗丽娜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LNNetWorkCache.h"
#import "AFNetWorking.h"
#import "AFNetworkActivityIndicatorManager.h"

typedef NS_ENUM(NSUInteger,LNNetWorkStatus) {
    //未知网络
    LNNetWorkStatusUnknown,
    //无网络
    LNNetWorkStatusNotReachable,
    //手机网络
    LNNetWorkStatusReachableWWAN,
    //WIFI网络
    LNNetWorkStatusReachableWIFi,
};


typedef NS_ENUM(NSUInteger, PPRequestSerializer) {
    /** 设置请求数据为JSON格式*/
    PPRequestSerializerJSON,
    /** 设置请求数据为二进制格式*/
    PPRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, PPResponseSerializer) {
    /** 设置响应数据为JSON格式*/
    PPResponseSerializerJSON,
    /** 设置响应数据为二进制格式*/
    PPResponseSerializerHTTP,
};

/** 请求成功的Block */
typedef void(^HttpRequestSuccess)(id responseObject);

/** 请求失败的Block */
typedef void(^HttpRequestFailed)(NSError *error);

/** 缓存的Block */
typedef void(^HttpRequestCache)(id responseCache);

/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小*/
typedef void (^HttpProgress)(NSProgress *progress);

/** 网络状态的Block*/
typedef void(^NetworkStatus)(LNNetWorkStatus status);

@interface LNAFNetWork : NSObject
/**
 *  实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
 */
+(void)networkStatusWithBlock:(NetworkStatus)networkStatus;






/**
 *  GET请求
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @parma isCache       是否缓存
 *  @param responseCache 缓存数据的回调
 *  @param success       请求成功的回调
 *  @param failure       请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(NSURLSessionTask *)GET:(NSString *)URL Parameters:(NSDictionary *)parameters IsCache:(BOOL) isCache ResponseCache:(HttpRequestCache)responseCache success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure;



/**
 * POST请求
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @parma isCache       是否缓存
 *  @param responseCache 缓存数据的回调
 *  @param success       请求成功的回调
 *  @param failure       请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(NSURLSessionTask *)POST:(NSString *)URL Parameters:(NSDictionary *)parameters IsCache:(BOOL) isCache ResponseCache:(HttpRequestCache)responseCache success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure;



/**
 * 判断是否存在缓存
 *
 *  @param URL           请求地址
 *  @param parameters    请求参数
 *  @return 返回存在结果
 */


+(id)isExistCacheWithURL:(NSString *)URL Parameters:(NSDictionary *)parameters;



/**
 *  上传图片文件
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param images     图片数组
 *  @param name       文件对应服务器上的字段
 *  @param fileName   文件名
 *  @param mimeType   图片文件的类型,例:png、jpeg(默认类型)....
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancel方法
 */
+(NSURLSessionTask *)UploadWithURL:(NSString *)URL Parameters:(NSDictionary *)parameters Images:(NSArray <UIImage *> * )images  Name:(NSString *)name FileName:(NSString *)fileName MimeType:(NSString *)mimeType Progress:(HttpProgress)progress Success:(HttpRequestSuccess)success Failure:(HttpRequestFailed)failure;

/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask
 */
+(NSURLSessionTask *)DownLoadWithURL:(NSString *)URL FileDir:(NSString *)fileDir Progress:(HttpProgress)progress Success:(void(^)(NSString * filePath)) success Failure:(HttpRequestFailed)failure;



#pragma mark - 重置AFHTTPSessionManager相关属性
/**
 *  设置网络请求参数的格式:默认为JSON格式
 *
 *  @param requestSerializer PPRequestSerializerJSON(JSON格式),PPRequestSerializerHTTP(二进制格式),
 */
+ (void)setRequestSerializer:(PPRequestSerializer)requestSerializer;

/**
 *  设置服务器响应数据格式:默认为JSON格式
 *
 *  @param responseSerializer PPResponseSerializerJSON(JSON格式),PPResponseSerializerHTTP(二进制格式)
 */
+ (void)setResponseSerializer:(PPResponseSerializer)responseSerializer;

/**
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 *  设置请求头
 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  是否打开网络状态转圈菊花:默认打开
 *
 *  @param open YES(打开), NO(关闭)
 */
+ (void)openNetworkActivityIndicator:(BOOL)open;
@end
