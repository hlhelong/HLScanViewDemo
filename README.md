/***
使用说明
****/
/*****
1、HLScanView文件夹拖入项目中
2、添加头文件：#import "HLScanViewController.h"
3、设置代理 <HLScanVCDelegate>
4、点击方法里面调用

    HLScanViewController *scanVC = [HLScanViewController scanViewController];
    scanVC.delegate = self;
    [self presentViewController:scanVC animated:YES completion:nil];
5、调用代理方法

    - (void)scanViewController:(UIViewController *)scanViewController codeInfo:(NSString *)codeInfo
    {
        NSLog(@"codeInfo-------------%@",codeInfo);
        NSURL *url = [NSURL URLWithString:codeInfo];
        if([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:url];
        }
    }



*****/