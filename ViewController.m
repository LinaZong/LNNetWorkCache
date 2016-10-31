//
//  ViewController.m
//  LNNetWorkCache
//
//  Created by 宗丽娜 on 16/10/19.
//  Copyright © 2016年 宗丽娜. All rights reserved.
//

#import "ViewController.h"
#import "LNAFNetWork.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *dataShow;



@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    NSString * dataURl  = @"http://www.qinto.com/wap/index.php?ctl=article_cate&act=api_app_getarticle_cate&num=1&p=7";

    //判断是否有缓存
    NSLog(@"网络缓存大小cache = %fMB",[LNNetWorkCache getAllHttpCacheSize]/1024/1024.f);

    if([LNAFNetWork isExistCacheWithURL:dataURl Parameters:nil]!= nil){
    //有缓存，加载缓存
        
        NSLog(@"缓存加载的数据");
        _dataShow.text =   [self jsonToString:[LNNetWorkCache httpCacheForURL:dataURl parameters:nil]];
        //没有缓存
    }else{
        
//        1.判断是否有网
        [LNAFNetWork networkStatusWithBlock:^(LNNetWorkStatus status) {
            switch (status) {
                    
                    case 0:
                case 1:{
                    break; 
                }
                   
                case LNNetWorkStatusReachableWWAN:
                case LNNetWorkStatusReachableWIFi: {
                    
                    [LNAFNetWork GET:dataURl Parameters:nil IsCache:YES ResponseCache:^(id responseCache) {
                        
                        
                    } success:^(id responseObject) {
                        //网络请求加载的数据
                        NSLog(@"网络加载的数据");
                        
                        _dataShow.text = [self jsonToString:responseObject];
                        
                    } Failure:^(NSError *error) {
                        
                    }];
                    NSLog(@"有网络,请求网络数据");
                    break;
            }
       
        }

            
        }];
        
       
    
    
}
}

- (IBAction)downLoad:(UIButton *)sender {
    
    
}


-(NSString *)jsonToString:(NSDictionary *)dic{
    
    if (!dic) {
        return nil;
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
