//
//  ViewController.m
//  HTMp3Audio Example
//
//  Created by HarveyTsang on 2020/12/4.
//

#import "ViewController.h"
//#import <HTMp3Audio/HTMp3Audio.h>
#import <HTMp3Audio/HTMp3Audio.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url = nil;
    HTMp3AudioRecorder *recorder = [[HTMp3AudioRecorder alloc] initWithURL:url settings:@{}];
    [recorder record];
}


@end
