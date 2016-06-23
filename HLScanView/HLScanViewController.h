//
//  HLScanViewController.h
//  saomiaoDemo
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLScanView;
@protocol HLScanVCDelegate<NSObject>

- (void)scanViewController:(UIViewController *)scanViewController codeInfo:(NSString *)codeInfo;

@end

@interface HLScanViewController : UIViewController

@property (nonatomic,weak) id<HLScanVCDelegate> delegate;

@property (nonatomic,strong) HLScanView *scanView;

+ (instancetype)scanViewController;

@end
