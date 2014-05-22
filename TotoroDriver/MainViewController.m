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
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self openTotora];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
}

- (void) openTotora {
    NSURL *url = [NSURL URLWithString:@"http://server.totorojs.org:9999/"];
//    NSURL *url = [NSURL URLWithString:@"http://localhost/_work/Projects/totorojs-ios-driver-test/alert.html"];
//    NSURL *url = [NSURL URLWithString:@"http://localhost/_work/Projects/totorojs-ios-driver-test/while-true.html"];
    [_labor loadRequest:[NSURLRequest requestWithURL:url]];
}


#pragma mark -
#pragma mark Delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start load");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish load");
    
    [_statusLabel setText:@"Started at: http://server.totorojs.org:9999/"];
    [_labor stringByEvaluatingJavaScriptFromString:@"document.body.style.background='#E0EAF1';"];
}


@end
