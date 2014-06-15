//
//  CCViewController.m
//  TotoroDriver
//
//  Created by 陈成 on 14-5-16.
//  Copyright (c) 2014年 ChenCheng. All rights reserved.
//


#import <mach/mach.h>
#import "MainViewController.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *labor;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet SocketIO *socketIO;

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set custom useragent
//    NSString *userAgent = [NSString stringWithFormat:@"ios/%@ webview for totora", [UIDevice currentDevice].systemVersion];
//    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:userAgent, @"UserAgent", nil];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    // Calculate cpu load intervally
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkCPU) userInfo:nil repeats:YES];

    // Init socketio connection
    [self setSocketIO:[[SocketIO alloc] initWithDelegate:self]];
    [_socketIO connectToHost:@"server.totorojs.org" onPort:9999 withParams:nil withNamespace:@"/__labor"];
}

- (void)checkCPU
{
//    NSLog(@"check cpu: %f", cpu_usage());
    [_statusLabel setText:[NSString stringWithFormat:@"CPU Usage: %.1f", cpu_usage()]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"memory warning");
}

- (void) openURL: (NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    [_labor loadRequest:[NSURLRequest requestWithURL:url]];
}


#pragma mark -
#pragma mark WebView Delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"%@", error);
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%@", request);
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start load");
    [_labor stringByEvaluatingJavaScriptFromString:@"window.alert = function() {};"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish load");
    [_labor stringByEvaluatingJavaScriptFromString:@"document.body.style.background='#E0EAF1';"];
}


#pragma mark -
#pragma mark SocketIO Delegates

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"socketio connected");
    
    [_labor stringByEvaluatingJavaScriptFromString:@"document.body.style.background='#E0EAF1';"];
    
    NSString *safariVersion = [_labor stringByEvaluatingJavaScriptFromString:@"navigator.userAgent.match(/AppleWebKit\\/(\\d+?)\\./)[1]/100"];
    NSDictionary *ua = @{@"device": @{@"name":@"ios"}, @"os":@{@"name":@"ios", @"version":[UIDevice currentDevice].systemVersion}, @"browser":@{@"name":@"iossafari", @"version":safariVersion}};
    [_socketIO sendEvent:@"init" withData:ua];
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    NSLog(@"error: %@", error);
    [_labor stringByEvaluatingJavaScriptFromString:@"document.body.style.background='red';"];
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error {
    NSLog(@"disconnect error: %@", error);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSDictionary *data = [packet.args objectAtIndex:0];
    
    if (!data) {
        return;
    }

    if (![packet.type isEqual: @"event"]) {
        return;
    }

//    NSString *key = [NSString stringWithFormat:@"%@-%@",
//                     [data objectForKey:@"orderId"],
//                     [data objectForKey:@"laborId"]];
    
    if ([packet.name isEqual: @"add"]) {
        NSLog(@"url: %@", [data objectForKey:@"url"]);
        [self openURL:[data objectForKey:@"url"]];
    }
    
    else if ([packet.name isEqualToString:@"remove"]) {
        [self openURL:@"about:blank"];
    }
}

#pragma mark -
#pragma mark Utils

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}


@end
