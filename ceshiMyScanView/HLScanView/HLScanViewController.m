//
//  HLScanViewController.m
//  saomiaoDemo
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#import "HLScanViewController.h"
#import "HLScanView.h"
#import "scan.h"

@interface HLScanViewController ()<HLScanViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>


@property (nonatomic,strong) UIView *navView;
@property (nonatomic,strong) UIButton *backBtn;
@property (nonatomic,strong) UIButton *flashlightBtn;
@property (nonatomic,strong) UIButton *photoBtn;

@property (nonatomic,assign) BOOL isOn;
@end

@implementation HLScanViewController

#pragma mark ---------初始化
+ (instancetype)scanViewController
{
    return [[self alloc] init];
}

- (instancetype)init
{
    if(self = [super init])
    {
        self.scanView = [HLScanView creatScanView];
        self.scanView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.navView];
}

#pragma mark --------生命周期（circle life）
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.scanView startScan];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.scanView stopSession];
}

- (void)dealloc
{
    [self.scanView stopScan];
}

#pragma mark --------添加导航控件
/**
 *  导航背景
 */
- (UIView *)navView
{
    if(!_navView)
    {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 64)];
        _navView.backgroundColor = [UIColor colorWithWhite:0.3f alpha:0.5];
//        _navView.alpha = 0.4f;
        [_navView addSubview:self.backBtn];
        [_navView addSubview:self.flashlightBtn];
        [_navView addSubview:self.photoBtn];
    }
    return _navView;
}
/**
 *  返回按钮
 */
- (UIButton *)backBtn
{
    if(!_backBtn)
    {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 27, 30, 30)];
        [_backBtn setImage:[UIImage imageNamed:[BUNDLE pathForResource:@"back.png" ofType:nil]] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
/**
 *  闪光灯
 */
- (UIButton *)flashlightBtn
{
    if(!_flashlightBtn)
    {
        _flashlightBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW*0.5-15, 27, 30, 30)];
        [_flashlightBtn setImage:[UIImage imageNamed:[BUNDLE pathForResource:@"light_on.png" ofType:nil]] forState:UIControlStateNormal];
        [_flashlightBtn addTarget:self action:@selector(clickLight) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightBtn;
}
/**
 *  闪光灯
 */
- (UIButton *)photoBtn
{
    if(!_photoBtn)
    {
        _photoBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenW-50, 27, 30, 30)];
        [_photoBtn setImage:[UIImage imageNamed:[BUNDLE pathForResource:@"photo.png" ofType:nil]] forState:UIControlStateNormal];
        [_photoBtn addTarget:self action:@selector(clickPhoto) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

#pragma mark -------点击按钮执行方法
/**
 *  返回
 */
- (void)clickBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  闪光灯
 */
- (void)clickLight
{
    if(!self.isOn)
    {
        [_flashlightBtn setImage:[UIImage imageNamed:[BUNDLE pathForResource:@"light_off.png" ofType:nil]] forState:UIControlStateNormal];
        [self.scanView turnLight:!self.isOn];
    }
    else
    {
        [_flashlightBtn setImage:[UIImage imageNamed:[BUNDLE pathForResource:@"light_on.png" ofType:nil]] forState:UIControlStateNormal];
        [self.scanView turnLight:!self.isOn];
    }
    self.isOn = !self.isOn;
}
/**
 *  相册扫描
 */
- (void)clickPhoto
{
    [self.scanView stopSession];

    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        //1.初始化相册拾取器
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        //2.设置代理
        controller.delegate = self;
        //3.设置资源：
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */
        controller.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //4.随便给他一个转场动画
        controller.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        controller.allowsEditing=YES;
        [self presentViewController:controller animated:YES completion:^{
        }];
        
    }else{
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark-> imagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /**这种方法是ios8之后提供的方法，ios8之前是不能用的,我尝试用之前的第三方去替代结果表示并不是很理想，很显然系统提供的api无论是从识别效率还是识别准确度上都要比第三方的强，我尝试用一个自定义背景色的二维码去被识别但是第三方提取不到信息，系统的可以提取到。这里说的取不到是在系统从相册中提取原图的时候上面的二维码信息提取不到，但是我这里把相册的编辑属性打开，取编辑之后的图片之后奇迹般的获取到了信息，真是奇葩 */
    //1.获取选择的图片
    if (iOS8) {
        UIImage *pickImage =[info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            
            [self decodeImage:pickImage];
        }];
    }
    return;
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.scanView startSession];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
/**识别图片中的二维码信息 */
-(void)decodeImage:(UIImage*)image{
    /**这里你完全可以向下兼容没必要用ios8以上的api但是这里这么写主要是为了介绍ios8后提供的这个api，而且性能和识别率要高于第三方 */
    if(iOS8){
        /**ios8环境以上 */
        
        //初始化一个监测器
        CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >=1) {
            /**结果对象 */
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"扫描结果" message:scannedResult delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            NSURL *url = [NSURL URLWithString:scannedResult];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else
            {
                [alertView show];
            }
        }
        else{
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该图片没有包含一个二维码！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }else{
        /**ios8环境以下 */
    }
    
}

#pragma mark -------HLScanViewDelegate  代理方法
- (void)scanView:(HLScanView *)scanView codeInfo:(NSString *)codeInfo
{
    if([self.delegate respondsToSelector:@selector(scanViewController:codeInfo:)])
    {
        [self.delegate scanViewController:self codeInfo:codeInfo];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
