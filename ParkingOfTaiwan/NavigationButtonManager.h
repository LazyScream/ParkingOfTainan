//
//  NavigationButtonManager.h
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/6/25.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationButtonManager : NSObject


+(void)openSlideMenu:(UIViewController * )view aboutMe:(NSString * )name list:(NSString * )listmode;
+(void)closeSlideMenu:(UIViewController * )view about:(NSString *)showName;



@end
