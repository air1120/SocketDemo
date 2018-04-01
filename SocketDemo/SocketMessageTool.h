//
//  SocketMessageTool.h
//  SocketDemo
//
//  Created by Rason on 2018/4/1.
//  Copyright © 2018年 Rason. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;
@interface SocketMessageTool : NSObject
+ (NSData *)dataForMessage:(NSString *)message;
+ (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag currentHead:(NSDictionary *__strong *)currentHead callback:(void (^)(NSString *content))callback;
@end
