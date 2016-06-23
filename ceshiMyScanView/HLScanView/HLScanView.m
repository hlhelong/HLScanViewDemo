//
//  HLScanView.m
//  saomiaoDemo
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#import "HLScanView.h"
#import <AVFoundation/AVFoundation.h>
#import "scan.h"

@interface HLScanView ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureDevice *device;
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,strong) CAShapeLayer *shadowLayer;
@property (nonatomic,strong) UIImageView *scanImg;
@property (nonatomic,strong) UIImageView *scanLineImg;

@property (nonatomic,assign) CGRect scanRect;
@property (nonatomic,strong) NSTimer *timer;
@end

@implementation HLScanView

#pragma mark ----------初始化
+ (instancetype)creatScanView
{
    return [[self alloc] initWithFrame:ScreenBounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f];
        self.scanType = 0;
    }
    return self;
}

#pragma mark -------生命周期（crcle life）
/**
 *  视图释放，捕捉停止
 */
- (void)dealloc
{
    [self stopScan];
}

#pragma  mark --------连接外部操作
/**
 *  开始扫描
 */
- (void)startScan
{
    if(!_session)
    {
        [self creatCaptureDevice];
    }
    [self.session startRunning];
    return;
}
/**
 *  停止扫描
 */
- (void)stopScan
{
    [self.session stopRunning];
    self.session = nil;
    [self.timer invalidate];
    self.scanImg = nil;
    [self removeFromSuperview];
}
- (void)startSession
{
    [self.session startRunning];
}
- (void)stopSession
{
    [self.session stopRunning];
}
/**
 *  闪光灯设置
 */
- (void)turnLight:(BOOL)on
{
    if ([self.device hasTorch] && [self.device hasFlash]){
        
        [self.device lockForConfiguration:nil];
        if (on) {
            [self.device setTorchMode:AVCaptureTorchModeOn];
            [self.device setFlashMode:AVCaptureFlashModeOn];
            
        } else {
            [self.device setTorchMode:AVCaptureTorchModeOff];
            [self.device setFlashMode:AVCaptureFlashModeOff];
        }
        [self.device unlockForConfiguration];
    }

}
#pragma mark ---------创建扫描捕获开启（capture）
/**
 *  初始化捕捉设备和其类型。创建媒体数据输入流,输出流
 */
- (void)creatCaptureDevice
{
    NSError *error;
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(!_input)
    {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    }
    if (!_input) {
        NSLog(@"%@", [error localizedDescription]);
        return;
    }
    [self.session addInput:_input];
    [self.session addOutput:self.output];
    if(self.scanType == 0)
    {
        [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
    }
    else if (self.scanType == 1)
    {
        [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,nil]];
    }
    else
    {
        [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, nil]];
    }
    [self.layer addSublayer:self.previewLayer];
    [self setupScanRect];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(moveScanLine:) userInfo:nil repeats:YES];
    [self.timer fire];
    [self.session startRunning];
}
/**
 *  实例化捕捉回话对象
 */
- (AVCaptureSession *)session
{
    if(!_session)
    {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh; //采集模式，高质量采集
    }
    return _session;
}
/**
 *  创建媒体数据输出流
 */
- (AVCaptureMetadataOutput *)output
{
    if(!_output)
    {
        _output = [[AVCaptureMetadataOutput alloc] init];
        //5.创建串行队列，并加媒体输出流添加到队列当中
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        //5.1.设置代理
        [_output setMetadataObjectsDelegate:self queue:dispatchQueue];
    }
    return _output;
}
/**
 *  实例化扫描图层
 */
- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if(!_previewLayer)
    {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.bounds;
    }
    return _previewLayer;
}

#pragma mark --------视图界面设置（layer）
/**
 *  扫描范围
 */
- (CGRect)scanRect
{
    if (CGRectEqualToRect(_scanRect, CGRectZero)) {
        CGRect rectOfInterest = self.output.rectOfInterest;
        CGFloat yOffset = rectOfInterest.size.width - rectOfInterest.origin.x;
        CGFloat xOffset = 0.7f;
        _scanRect = CGRectMake(rectOfInterest.origin.y * ScreenW, rectOfInterest.origin.x * ScreenH, xOffset * ScreenW, yOffset * ScreenH);
    }
    return _scanRect;

}

// 阴影层
- (CAShapeLayer *)shadowLayer
{
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect: self.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.75].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    return _shadowLayer;
}

// 遮掩层
- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect: ScreenBounds exceptRect: self.scanRect];
    }
    return _maskLayer;
}
/**
 *  绘制扫描框
 */
- (UIImageView *)scanImg
{
    if(!_scanImg)
    {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x -= 2;
        scanRect.origin.y -= 2;
        scanRect.size.width += 4;
        scanRect.size.height += 4;

        _scanImg = [[UIImageView alloc] init];
        _scanImg.frame = scanRect;
        _scanImg.image = [UIImage imageNamed:[BUNDLE pathForResource:@"scan.png" ofType:nil]];
        _scanImg.backgroundColor = [UIColor clearColor];
    }
    return _scanImg;
}
/**
 *  绘制扫描条
 */
- (UIImageView *)scanLineImg
{
    if(!_scanLineImg)
    {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x += 10;
        scanRect.origin.y += 10;
        scanRect.size.width -= 20;
        scanRect.size.height = 10;
        
        _scanLineImg = [[UIImageView alloc] init];
        _scanLineImg.frame = scanRect;
        _scanLineImg.image = [UIImage imageNamed:[BUNDLE pathForResource:@"scan_line.png" ofType:nil]];

    }
    return _scanLineImg;
}
/**
 *  扫描条上下滚动
 */
- (void)moveScanLine:(NSTimer *)timer
{
    CABasicAnimation *baseAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    baseAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(ScreenW*0.5, self.scanRect.origin.y+15)];
    baseAnimation.toValue  = [NSValue valueWithCGPoint:CGPointMake(ScreenW*0.5, self.scanRect.origin.y+self.scanRect.size.height-30)];
    baseAnimation.duration = 3.0f;
    [self.scanLineImg.layer addAnimation:baseAnimation forKey:@"lineMoveAnimation"];
}
// 配置扫描范围
- (void)setupScanRect
{
    CGFloat size = ScreenW * 0.7;
    CGFloat minY = (ScreenH - size) * 0.5 / ScreenH;
    CGFloat maxY = (ScreenH + size) * 0.5 / ScreenH;
    self.output.rectOfInterest = CGRectMake(minY, 0.15, maxY, 0.7);
    
    [self.layer addSublayer: self.shadowLayer];
    [self addSubview:self.scanImg];
    [self addSubview:self.scanLineImg];
}

#pragma mark - generate
// 生成空缺部分rect的layer
- (CAShapeLayer *)generateMaskLayerWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    else if (CGRectEqualToRect(rect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect: rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    // 添加路径
    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

#pragma mark ----------代理方法

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if(metadataObjects.count > 0)
    {
        AVMetadataMachineReadableCodeObject *metaObject = metadataObjects[0];
        if([self.delegate respondsToSelector:@selector(scanView:codeInfo:)])
        {
            [self.delegate scanView:self codeInfo:metaObject.stringValue];
            [self stopScan];
        }
    }
}
@end
