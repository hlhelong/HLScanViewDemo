//
//  scan.h
//  saomiaoDemo
//
//  Created by helong on 16/6/23.
//  Copyright © 2016年 helong. All rights reserved.
//

#ifndef scan_h
#define scan_h

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define iOS8 [[UIDevice currentDevice].systemVersion floatValue] >= 8.0
#define BUNDLE [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"scan" ofType:@"bundle"]]
#define ScreenBounds [UIScreen mainScreen].bounds


#endif /* scan_h */
