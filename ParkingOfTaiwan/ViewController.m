//
//  ViewController.m
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/5/26.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import "ViewController.h"
#import "MyTableViewController.h"
#import "Reachability.h"
//↓匯入地圖與定位系統
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AdSupport/AdSupport.h>
//↓加入Delegate
@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UITableViewDelegate>
{       //↓宣告變數
    int a ;
    BOOL firstLocationReceived;
    CLLocationManager * LocationManager;
    NSDictionary * onelist;
    CLLocationCoordinate2D mapCenter;
    MKPointAnnotation * point;
    NSMutableArray * parkingName ;
    NSMutableArray * parkingSpeac;
    NSMutableArray * parkingCarMoney;
    NSMutableArray * parkingLocationX;
    NSMutableArray * parkingLocationY;
    NSMutableArray * parkingMotoSpeac;
}
@property (nonatomic,strong) Reachability * reachaBility;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (nonatomic) NSMutableArray * jsonInfo;
@property (nonatomic) CLLocationCoordinate2D targetCoordinate;
@property (nonatomic) NSString * placeName;
@property (nonatomic) NSString * name;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
#pragma mark 檢測網路連線
    Reachability * networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus =[networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertController * noInterNet =[UIAlertController alertControllerWithTitle:@"網路異常，請連接網路" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [noInterNet addAction:ok];
        [self presentViewController:noInterNet animated:true completion:nil];
    }
    else{
        Reachability * reachability =[Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        NetworkStatus status =[reachability currentReachabilityStatus];
        if (status == NotReachable) {
            
        }
    }
    
    //↓讓畫面一開啟就讀取下面方法
    parkingLocationX = [NSMutableArray new];
    parkingLocationY = [NSMutableArray new];
    parkingSpeac = [NSMutableArray new];
    parkingName =[NSMutableArray new];
    parkingCarMoney = [NSMutableArray new];
    parkingMotoSpeac= [NSMutableArray new];

    [self findParkingLocation1];
    [self findParkingLocation2];
    [self findParkingLocation3];
    //↓地圖使用時機 - 設為永久
    LocationManager = [CLLocationManager new];
    if ([LocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        //↓設定方法
        [LocationManager requestAlwaysAuthorization];
    }
    //↓啟動Location   //↓精確度
    LocationManager.desiredAccuracy = kCLLocationAccuracyBest;
                    //↓型態
    LocationManager.activityType = CLActivityTypeAutomotiveNavigation;
                    //↓把自己委託給定位管理器
    LocationManager.delegate = self;
                    //↓委託之後必須開始更新位置
    [LocationManager startUpdatingLocation];
    
    self.adBannerView.adUnitID = @"ca-app-pub-2389976347145895/5734014362";
    
    self.adBannerView.rootViewController = self;
    //↓準備 google ad request
    GADRequest * request = [GADRequest request];
    request.testDevices = @[@"609707ad65bcc85ee2cf9bce387d7484"];
    //↓請bannerview載入
    [self.adBannerView loadRequest:request];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

    //↓把切換控制器拉進來作為一個IBAction
- (IBAction)locationAndTrack:(UISegmentedControl *)sender {
    //↓給索引值一個變數名稱，索引值為整數故使用NSInteger
    NSInteger targetIndex = sender.selectedSegmentIndex;
    //↓使用切換開關來控制與設定其內容
    switch (targetIndex) {
        case 0:
            [self defultLocation];
            break;
        case 1:
            self.mainMapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case 2:
            self.mainMapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            break;
        default:
            break;
    }
}
#pragma mark  定位管理器的方法實作
//↓無回傳值的方法，更新位置
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //↓預設位置進入點
    mapCenter.latitude = 22.992282;
    mapCenter.longitude = 120.195134;
    //↓印出自己的位作為測試
    //NSLog(@"%.6f,%.6f",mapCenter.latitude,mapCenter.longitude);
    static dispatch_once_t changRegionOnceToken;
    //↓確保自己的程式碼只Run一次
    dispatch_once(&changRegionOnceToken, ^{
    //↓建立地圖中心跟縮放比的類別，座標區域命名然後取代主地圖
    MKCoordinateRegion regoin = self.mainMapView.region;
    //↓使用regoin來定位中心
    regoin.center = mapCenter;
    //↓地圖中心的經緯度縮放比
    regoin.span.latitudeDelta = 0.10;
    regoin.span.longitudeDelta= 0.10;
    //↓設定動畫在主畫面顯示方法
    [self.mainMapView setRegion:regoin animated:true];
    firstLocationReceived = true;
    });
}
#pragma mark 按下大頭針並且拉近
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    [self getPinLocation];
    mapCenter.latitude += 0.0010;
    mapCenter.longitude+= 0.0010;
    MKCoordinateRegion regoin = self.mainMapView.region;
    regoin.center = _targetCoordinate;
    regoin.span.latitudeDelta = 0.02;
    regoin.span.longitudeDelta= 0.02;
    [self.mainMapView setRegion:regoin animated:true];
    firstLocationReceived = true;
}
#pragma mark 定位回去到初始位置
-(void)defultLocation{
    mapCenter.latitude = 22.992282;
    mapCenter.longitude = 120.195134;
    MKCoordinateRegion regoin = self.mainMapView.region;
    regoin.center = mapCenter;
    regoin.span.latitudeDelta = 0.05;
    regoin.span.longitudeDelta= 0.05;
    [self.mainMapView setRegion:regoin animated:true];
    firstLocationReceived = true;
    //NSLog(@"%.6f,%.6f",mapCenter.latitude,mapCenter.longitude);
}
#pragma mark 打開地圖
-(void)openMap:(CLPlacemark*)targetPlacemark{
    MKPlacemark * place = [[MKPlacemark alloc]initWithPlacemark:targetPlacemark];
    MKMapItem * mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    mapItem.name = self.placeName;
    NSDictionary * options = @{
    MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
    };
    [mapItem openInMapsWithLaunchOptions:options];
}
#pragma mark 頭針相關設定
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(nonnull id <MKAnnotation>)annotation {
    if (annotation ==mV.userLocation) {
        return nil;
    }
    static NSString * defaultPinID = @"Pin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.mainMapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if(pinView == nil)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
    }
#pragma mark ℹ︎按鈕
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton addTarget:self action:@selector(addToListButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = detailButton;
    pinView.animatesDrop = false;
    pinView.canShowCallout = YES;
    
    [pinView setSelected:YES animated:YES];
    
    
    return pinView;
    
}
#pragma mark alert按鈕
-(void)addToListButtonTapped:(id)sender
{
    //↓表格框的title文字
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:@"停車資訊" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //↓設定按鈕1還有設定按鈕1進入導航功能
    UIAlertAction * navigationBT = [UIAlertAction actionWithTitle:@"導航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self getPinLocation];
        MKPlacemark * place = [[MKPlacemark alloc]initWithCoordinate:self.targetCoordinate addressDictionary:nil];
        [self openMap:place];
                                }];
    //↓設定按鈕2目前為回主畫面
    UIAlertAction * telphoneBT = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    //↓啟動這兩個按鍵
    [alert addAction:navigationBT];
    [alert addAction:telphoneBT];
    //    顯示提示視窗
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark 臺南市公有收費停車場
-(void)findParkingLocation1{
    //↓宣告網址的變數讓後面可以使用
    NSString * jsonURL = @"http://163.29.141.11/App/parking.ashx?verCode=5177E3481D&type=2&ftype=1&exportTo=2";
    //↓把網址轉成可用的連結
    NSURL * url = [NSURL URLWithString:jsonURL];
    //↓連結的類型修改為即時
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            return ;
        }
        //↓載入json資料內容
        self.jsonInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray * json = [[NSArray alloc]initWithArray:self.jsonInfo];
        for (int i=0; i<json.count; i++) {
            
            CLLocationCoordinate2D  LocationCoordinates;
            onelist = json[i];
            NSString * fromJson = [onelist objectForKey:@"經緯度"];
            if ([onelist objectForKey:@"經緯度"] == [NSNull null]) {
                
            }else{
                NSArray * cutString = [fromJson componentsSeparatedByString:@"，"];
                NSString * locationX = cutString[0];
                NSString * locationY = cutString[1];
                LocationCoordinates.latitude  = locationX.floatValue;
                LocationCoordinates.longitude = locationY.floatValue;
                
                _name = [onelist objectForKey:@"停車場名稱"];
                NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
                NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
                NSString * parkingSpeacToCell = [onelist objectForKey:@"小型車(一般)"];
                NSString * parkingMotoSpeacToCell = [onelist objectForKey:@"機車(一般)"];
                
                
                [parkingSpeac addObject:parkingSpeacToCell];
                [parkingName addObject:forTableCell];
                [parkingCarMoney addObject:parkingMoneyToCell];
                [parkingMotoSpeac addObject:parkingMotoSpeacToCell];
                [parkingLocationX addObject:locationX];
                [parkingLocationY addObject:locationY];
                
                
                point = [MKPointAnnotation new];
                point.coordinate = LocationCoordinates;
                point.title = _name;
                [self.mainMapView addAnnotation:point];
        
            }
        }
        
    }];
    [task resume];
}
#pragma mark 臺南市公有免費停車場
-(void)findParkingLocation2{
    //↓宣告網址的變數讓後面可以使用
    NSString * jsonURL = @"http://163.29.141.11/App/parking.ashx?verCode=5177E3481D&type=1&ftype=1&exportTo=2";
    //↓把網址轉成可用的連結
    NSURL * url = [NSURL URLWithString:jsonURL];
    //↓連結的類型修改為即時
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            return ;
        }
        //↓載入json資料內容
        self.jsonInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray * json = [[NSArray alloc]initWithArray:self.jsonInfo];
        for (int i=0; i<62; i++) {
            
            CLLocationCoordinate2D  LocationCoordinates;
            onelist = json[i];
            NSString * fromJson = [onelist objectForKey:@"經緯度"];
            
                
                NSArray * cutString = [fromJson componentsSeparatedByString:@"，"];
                NSString * locationX = cutString[0];
                NSString * locationY = cutString[1];
                LocationCoordinates.latitude  = locationX.floatValue;
                LocationCoordinates.longitude = locationY.floatValue;
                _name = [onelist objectForKey:@"停車場名稱"];
                NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
                NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
                NSString * parkingSpeacToCell = [onelist objectForKey:@"小型車(一般)"];
                NSString * parkingMotoSpeacToCell = [onelist objectForKey:@"機車(一般)"];
                [parkingMotoSpeac addObject:parkingMotoSpeacToCell];
                [parkingSpeac addObject:parkingSpeacToCell];
                [parkingCarMoney addObject:parkingMoneyToCell];
                [parkingName addObject:forTableCell];
                [parkingLocationX addObject:locationX];
                [parkingLocationY addObject:locationY];
                
                
                
                point = [MKPointAnnotation new];
                point.coordinate = LocationCoordinates;
                point.title = _name;
                [self.mainMapView addAnnotation:point];
        }
        
    }];
    [task resume];
}
#pragma mark 民營停車場
-(void)findParkingLocation3{
    //↓宣告網址的變數讓後面可以使用
    NSString * jsonURL = @"http://163.29.141.11/App/parking.ashx?verCode=5177E3481D&type=3&ftype=1&exportTo=2";
    //↓把網址轉成可用的連結
    NSURL * url = [NSURL URLWithString:jsonURL];
    //↓連結的類型修改為即時
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            return ;
        }
        //↓載入json資料內容
        self.jsonInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray * json = [[NSArray alloc]initWithArray:self.jsonInfo];
        for (int i=0; i<json.count; i++) {
            
            CLLocationCoordinate2D  LocationCoordinates;
            onelist = json[i];
            NSString * fromJson = [onelist valueForKey:@"經緯度"];
            _name = [onelist objectForKey:@"停車場名稱"];
            if ([onelist valueForKey:@"經緯度"] == [NSNull null]) {
                
            }else{
            NSArray * cutString = [fromJson componentsSeparatedByString:@"，"];
            NSString * locationX = cutString[0];
            NSString * locationY = cutString[1];
            LocationCoordinates.latitude  = locationX.floatValue;
            LocationCoordinates.longitude = locationY.floatValue;
            _name = [onelist objectForKey:@"停車場名稱"];
            NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
            NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
            NSString * parkingSpeacToCell = [onelist objectForKey:@"小型車(一般)"];
            NSString * parkingMotoSpeacToCell = [onelist objectForKey:@"機車(一般)"];
            [parkingMotoSpeac addObject:parkingMotoSpeacToCell];
            [parkingSpeac addObject:parkingSpeacToCell];
            [parkingCarMoney addObject:parkingMoneyToCell];
            [parkingName addObject:forTableCell];
            [parkingLocationX addObject:locationX];
            [parkingLocationY addObject:locationY];
            
            point = [MKPointAnnotation new];
            point.coordinate = LocationCoordinates;
            point.title = _name;
            [self.mainMapView addAnnotation:point];
            }
        }
        
    }];
    [task resume];
}
#pragma mark 導航前領取頭針資訊
//↓在進入導航時候拿取頭針上的資訊 包刮經緯度 名稱 可再新增
-(void)getPinLocation{
    if (self.mainMapView.selectedAnnotations.count == 0)
    {
        NSLog(@"no annotation selected");
    }
    else
    {
        id<MKAnnotation> pin = [self.mainMapView.selectedAnnotations objectAtIndex:0];
        
        self.targetCoordinate = pin.coordinate;
        self.placeName = pin.title;
    }
    
}
#pragma mark 資料丟過去TableView
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyTableViewController*nameToCell = segue.destinationViewController;
    nameToCell.allNameList = [NSMutableArray arrayWithArray:parkingName];
    
    MyTableViewController*moneyToCell = segue.destinationViewController;
    moneyToCell.PKMoney = [NSMutableArray arrayWithArray:parkingCarMoney];
    
    MyTableViewController*speacToCell = segue.destinationViewController;
    speacToCell.PKCarSpeac = [NSMutableArray arrayWithArray:parkingSpeac];
    
    MyTableViewController*motoToCell = segue.destinationViewController;
    motoToCell.PKMotoSpeac =  [NSMutableArray arrayWithArray:parkingMotoSpeac];
    
    MyTableViewController*locationXToCell = segue.destinationViewController;
    locationXToCell.PKLocationX = [NSMutableArray arrayWithArray:parkingLocationX];
    
    MyTableViewController*locationYToCell = segue.destinationViewController;
    locationYToCell.PKLocationY = [NSMutableArray arrayWithArray:parkingLocationY];
    
    
    
}

#pragma mark 網路狀態改變時vc會得到通知
-(void)networkReachabilityChanged:(NSNotification *)note{
    Reachability * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        
    }
}
@end
