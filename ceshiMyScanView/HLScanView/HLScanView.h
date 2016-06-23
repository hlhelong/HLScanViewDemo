//
//  HLScanView.h
//  saomiaoDemo
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  二维码扫描类型
 */
typedef NS_ENUM(NSInteger,HLScanType) {

    HLScanTypeBothCode,//默认从0开始
    HLScanTypeQRCode,
    HLScanTypeBarCode,
};

@class HLScanView;
@protocol HLScanViewDelegate <NSObject>

- (void)scanView:(HLScanView *)scanView codeInfo:(NSString *)codeInfo;

@end

@interface HLScanView : UIView
/**
 *  二维码扫描类型，默认为HLScanTypeBothCode
 */
@property (nonatomic,assign) HLScanType scanType;

/**
 *  扫描成功回调代理，传递扫描所得内容
 */
@property (nonatomic,weak) id<HLScanViewDelegate> delegate;

/**
 *  创建扫描视图
 *
 *  @return 返回HLScanView
 */
+ (instancetype)creatScanView;

/**
 *  外部使用接口，开始、停止扫描控制
 */
- (void)startScan;
- (void)stopScan;
- (void)turnLight:(BOOL)on;
- (void)startSession;
- (void)stopSession;
@end
