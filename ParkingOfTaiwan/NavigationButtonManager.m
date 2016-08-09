//
//  NavigationButtonManager.m
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/6/25.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import "NavigationButtonManager.h"

@implementation NavigationButtonManager


+(void)openSlideMenu:(UIViewController * )view aboutMe:(NSString * )name list:(NSString * )listmode{
    
    
    view.navigationItem.leftBarButtonItem.title = name;
    view.navigationItem.rightBarButtonItem.title = listmode;
    view.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}
+(void)closeSlideMenu:(UIViewController * )view about:(NSString *)showName;
{
    
    view.navigationItem.leftBarButtonItem.title = showName;
    view.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.800 green:0.302 blue:0.271 alpha:1.00];
}

@end
