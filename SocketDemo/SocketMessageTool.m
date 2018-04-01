//
//  SocketMessageTool.m
//  SocketDemo
//
//  Created by Rason on 2018/4/1.
//  Copyright © 2018年 Rason. All rights reserved.
//

#import "SocketMessageTool.h"
#import "GCDAsyncSocket.h"
@implementation SocketMessageTool
+ (NSData *)dataForMessage:(NSString *)message{
    //内容数据
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //拼接头部数据
    NSMutableDictionary *lengthDic = [NSMutableDictionary dictionary];
    [lengthDic setObject:@"text" forKey:@"type"];
    [lengthDic setObject:[NSString stringWithFormat:@"%lu",data.length] forKey:@"size"];
    
    //以某标识分割
    NSError *error;
    NSData *lengthDate = [NSJSONSerialization dataWithJSONObject:lengthDic options:NSJSONReadingMutableContainers error:&error];
    NSMutableData *mutableDate  = [NSMutableData dataWithData:lengthDate];
    [mutableDate appendData:[GCDAsyncSocket CRLFData]];
    [mutableDate appendData:data];
    return mutableDate;
}
+ (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag currentHead:(NSDictionary *__strong *)currentHead callback:(void (^)(NSString *content))callback {//currentHead
    NSDictionary  *currentDic = *currentHead;
    //如果不存在头文件的话，就说明当前需要获取头信息
    if (!currentDic) {
        *currentHead = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSInteger length = [[*currentHead valueForKey:@"size"] integerValue];
        [sock readDataToLength:length withTimeout:-1 tag:0];
        return ;
    }
    
    NSInteger length = [[currentDic valueForKey:@"size"] integerValue];
    if (length <0 || length !=[data length]) {
        [sock disconnect];
        NSLog(@"%@",@"出错");
        return ;
    }
    NSString *type = [currentDic valueForKey:@"type"];
    NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([type isEqualToString:@"text"]) {
        NSLog(@"content:%@",content);
        if(callback){
            callback(content);
        }
    }else{
        NSLog(@"%@",@"其它类型");
    }
    *currentHead = nil;
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}
@end
