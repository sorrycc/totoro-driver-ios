//
//  CCViewController.m
//  TotoroDriver
//
//  Created by 陈成 on 14-5-16.
//  Copyright (c) 2014年 ChenCheng. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *labor;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self openTotora];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) openTotora {
    NSURL *url = [NSURL URLWithString:@"http://server.totorojs.org:9999/"];
    [_labor loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}

@end
