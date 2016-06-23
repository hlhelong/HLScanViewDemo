//
//  ViewController.m
//  ceshiMyScanView
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#import "ViewController.h"
#import "HLScanViewController.h"

@interface ViewController ()<HLScanVCDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(100, 100, 100, 50);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)clickBtn
{
    HLScanViewController *scanVC = [HLScanViewController scanViewController];
    scanVC.delegate = self;
    [self presentViewController:scanVC animated:YES completion:nil];
}

#pragma mark -----HLScanVCDelegate

- (void)scanViewController:(UIViewController *)scanViewController codeInfo:(NSString *)codeInfo
{
    NSLog(@"codeInfo-------------%@",codeInfo);
    NSURL *url = [NSURL URLWithString:codeInfo];
    if([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
