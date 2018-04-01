//
//  ServerViewController.m
//  SocketDemo
//
//  Created by Elaine on 17/3/5.
//  Copyright © 2017年 Rason. All rights reserved.
//

#import "ServerViewController.h"
#import "SocketMessageTool.h"
// 使用CocoPods使用<>, 可以指定路径
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
@interface ServerViewController ()<GCDAsyncSocketDelegate>{
    NSDictionary *currentDic;
}

@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextView *message; // 多行文本输入框
@property (weak, nonatomic) IBOutlet UITextField *content;

@property (nonatomic, strong) GCDAsyncSocket *clientSocket;// 为客户端生成的socket

// 服务器socket
@property (nonatomic, strong) GCDAsyncSocket *serverSocket;

@end

@implementation ServerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// 服务端监听某个端口
- (IBAction)listen:(UIButton *)sender
{
    // 1. 创建服务器socket
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 2. 开放哪些端口
    NSError *error = nil;
    uint16_t ipNum = self.portTF.text.integerValue?self.portTF.text.integerValue:8080;
    BOOL result = [self.serverSocket acceptOnPort:ipNum error:&error];
    
    // 3. 判断端口号是否开放成功
    if (result) {
        [self addText:[NSString stringWithFormat:@"%i端口开放成功",ipNum]];
    } else {
        [self addText:[NSString stringWithFormat:@"%i端口开放失败,%@",ipNum,error]];
    }
}

// 发送
- (IBAction)sendMessage:(UIButton *)sender
{
    
    NSData *mutableDate = [SocketMessageTool dataForMessage:self.content.text];
    [self.clientSocket writeData:mutableDate withTimeout:-1 tag:0];
    [self.clientSocket writeData:mutableDate withTimeout:-1 tag:0];
    [self.clientSocket writeData:mutableDate withTimeout:-1 tag:0];
    [self.clientSocket writeData:mutableDate withTimeout:-1 tag:0];
    [self.clientSocket writeData:mutableDate withTimeout:-1 tag:0];
    
    //确认一下
//    [self.clientSocket readDataWithTimeout:-1 tag:0];
//    [socket.mySocket readDataWithTimeout:-1 tag:0];
}


// 断开链接
- (IBAction)disconnectSocket:(UIButton *)sender
{
    [self.clientSocket disconnect];
    self.clientSocket = nil;
}


// textView填写内容
- (void)addText:(NSString *)text
{
    self.message.text = [self.message.text stringByAppendingFormat:@"%@\n", text];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - GCDAsyncSocketDelegate
// 当客户端链接服务器端的socket, 为客户端单生成一个socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [self addText:@"链接成功"];
    //IP: newSocket.connectedHost
    //端口号: newSocket.connectedPort
    [self addText:[NSString stringWithFormat:@"链接地址:%@", newSocket.connectedHost]];
    [self addText:[NSString stringWithFormat:@"端口号:%hu", newSocket.connectedPort]];
    // short: %hd
    // unsigned short: %hu
    
    // 存储新的端口号
    self.clientSocket = newSocket;
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [SocketMessageTool socket:sock didReadData:data withTag:tag currentHead:&currentDic callback:^(NSString *content){
        NSLog(@"content--------%@",content);
        [self addText:content];
//        [self addText:content];
    }];
}

@end
