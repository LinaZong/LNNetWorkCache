//
//  LNNetWorkCache.h
//  LNNetWorkCache
//
//  Created by 宗丽娜 on 16/10/19.
//  Copyright © 2016年 宗丽娜. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 网络缓存类
@interface LNNetWorkCache : NSObject

/**
 *  缓存网络数据,根据请求的 URL与parameters
 *  做KEY存储数据, 这样就能缓存多级页面的数据
 *
 *  @param httpData   服务器返回的数据
 *  @param url        请求的URL地址
 *  @param parameters 请求的参数
 */
+(void)setHttpCache:(id)httpData URL:(NSString *)url Parameters:(NSDictionary *)parameters;


/**
 *  根据请求的 URL与parameters 取出缓存数据
 *
 *  @param url       请求的URL
 *  @param parameters 请求的参数
 *
 *  @return 缓存的服务器数据
 */
+(id)httpCacheForURL:(NSString *)url parameters:(NSDictionary *)parameters;

/**
 *  获取网络缓存的总大小 bytes(字节)
 */
+ (NSInteger)getAllHttpCacheSize;


/**
 *  删除所有网络缓存,
 */
+ (void)removeAllHttpCache;

@end
