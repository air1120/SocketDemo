//
//  ClientTableViewController.m
//  SocketDemo
//
//  Created by Elaine on 17/3/5.
//  Copyright © 2017年 Rason. All rights reserved.
//

#import "ClientTableViewController.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "SocketMessageTool.h"
typedef enum{
    SocketOfflineTypeByServer,// 服务器掉线，默认为0
    SocketOfflineTypeByUser,  // 用户主动cut
}SocketOfflineType;

@interface ClientTableViewController ()<GCDAsyncSocketDelegate>{
    SocketOfflineType offlineType;
    NSDictionary  *currentDic;
}

/**
 * 当前头信息
 **/
//@property (nonatomic, assign) NSDictionary  *currentDic;

@property (weak, nonatomic) IBOutlet UITextField *addressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;
@property (weak, nonatomic) IBOutlet UITextField *message;
/**
 * 心跳计时器
 **/
@property (nonatomic, strong) NSTimer *connectTimer;

@property (weak, nonatomic) IBOutlet UITextView *content;

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation ClientTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

// 和服务器进行链接
- (IBAction)connect:(UIButton *)sender
{
    // 1. 创建socket
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // 2. 与服务器的socket链接起来
    NSError *error = nil;
    uint16_t ipNum = self.portTF.text.integerValue?self.portTF.text.integerValue:8080;
    BOOL result = [self.socket connectToHost:[self.addressTF.text isEqualToString:@""]?@"127.0.0.1":self.addressTF.text onPort:ipNum error:&error];
    
    // 3. 判断链接是否成功
    if (result) {
        [self addText:@"客户端链接服务器成功"];
    } else {
        [self addText:@"客户端链接服务器失败"];
    }
}

// 接收数据
- (IBAction)disconnectSocketByUser:(UIButton *)sender
{
    offlineType = SocketOfflineTypeByUser;
    [self.socket disconnect];
}

// 发送消息
- (IBAction)sendMassage:(UIButton *)sender
{
    
    [self.socket writeData:[SocketMessageTool dataForMessage:self.message.text] withTimeout:-1 tag:0];
}


// textView填写内容
- (void)addText:(NSString *)text
{
    self.content.text = [self.content.text stringByAppendingFormat:@"%@\n", text];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GCDAsyncSocketDelegate

// 客户端链接服务器端成功, 客户端获取地址和端口号
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self addText:[NSString stringWithFormat:@"链接服务器%@", host]];
    self.socket = sock;
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    
}
- (void)createConnectTimer{
    __weak typeof(self) weakSelf = self;
    
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:10 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf.socket writeData:[SocketMessageTool dataForMessage:@""] withTimeout:-1 tag:0];
    }];
}
// 客户端已经获取到内容
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    NSDictionary *dic = currentDic;
    [SocketMessageTool socket:sock didReadData:data withTag:tag currentHead:&currentDic callback:^(NSString *content){
       NSLog(@"content--------%@",content);
        [self addText:content];
    }];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    NSLog(@"socket断开原因：%@",err);
    if (offlineType == SocketOfflineTypeByServer) {
        NSString *tip = @"正在进行重新链接...";
        NSLog(@"%@",tip);
        [self addText:tip];
        [self connect:nil];
    } else if(offlineType == SocketOfflineTypeByUser){
        NSString *tip = @"用户自己断开，不进行自动重连";
        NSLog(@"%@",tip);
        [self addText:tip];
    }
    
}
@end
