//
//  UIApplication+ZBAnalytics.h
//  ZBKit
//
//  Created by NQ UEC on 17/3/1.
//  Copyright © 2017年 Suzhibin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (ZBAnalytics)
- (UIViewController *)topMostViewController;
- (UIViewController *)currentViewController;
@end
