//
//  LNNetWorkCache.m
//  LNNetWorkCache
//
//  Created by 宗丽娜 on 16/10/19.
//  Copyright © 2016年 宗丽娜. All rights reserved.
//

#import "LNNetWorkCache.h"
#import "YYCache.h"

@implementation LNNetWorkCache
static NSString *const NetworkResponseCache = @"NetworkResponseCache";
static YYCache *_dataCache;
+(void)initialize{
    
    _dataCache = [YYCache cacheWithName:NetworkResponseCache];
    
  
    
}
+(void)setHttpCache:(id)httpData URL:(NSString *)url Parameters:(NSDictionary *)parameters{
    
    NSString * cacheKey = [self cacheKeyWithURL:url parameters:parameters];
    //异步缓存防止阻塞线程
    [_dataCache setObject:httpData forKey:cacheKey withBlock:nil];
    
    
}
+(id)httpCacheForURL:(NSString *)url parameters:(NSDictionary *)parameters{
   
    NSString * cacheKey = [self cacheKeyWithURL:url parameters:parameters];
    
    return [_dataCache objectForKey:cacheKey];
    
}
+ (NSInteger)getAllHttpCacheSize{
    NSLog(@"内存缓存 %ld", [_dataCache.memoryCache totalCost]);
    return [_dataCache.diskCache totalCost];
    
}
+ (void)removeAllHttpCache{
    [_dataCache removeAllObjects];
}


+(NSString * )cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters{
    
    if (!parameters) {
        return  URL;
    };
    
    
    //将参数字典转换成字符串
    NSData * stringData = [NSJSONSerialization  dataWithJSONObject:parameters options:0 error:nil];
    
    
    NSString * paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
 
     //将URL与转换好的参数字符串拼接在一起，成为最终存储的KEY值
    NSString * cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];

    return cacheKey;
    
}
@end
