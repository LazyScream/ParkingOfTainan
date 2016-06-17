//
//  MyTableViewController.h
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/6/3.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTableViewController : UITableViewController
@property(strong,nonatomic)NSMutableArray * allNameList;
@property(strong,nonatomic)NSMutableArray * PKMoney;
@property(strong,nonatomic)NSMutableArray * PKCarSpeac;
@property(strong,nonatomic)NSMutableArray * PKMotoSpeac;
@property(strong,nonatomic)NSMutableArray * PKLocationX;
@property(strong,nonatomic)NSMutableArray * PKLocationY;
@end
