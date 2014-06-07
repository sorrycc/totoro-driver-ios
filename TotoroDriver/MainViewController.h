//
//  CCViewController.h
//  TotoroDriver
//
//  Created by 陈成 on 14-5-16.
//  Copyright (c) 2014年 ChenCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <socket.IO/SocketIO.h>
#import <socket.IO/SocketIOPacket.h>

@interface MainViewController : UIViewController<UIWebViewDelegate, SocketIODelegate>

@end
