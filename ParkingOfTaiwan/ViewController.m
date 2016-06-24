//
//  ViewController.m
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/5/26.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import "ViewController.h"
#import "LLSlideMenu.h"
#import "MyTableViewController.h"
#import "Reachability.h"

//↓匯入地圖與定位系統
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <AdSupport/AdSupport.h>
#import <MessageUI/MessageUI.h>
//↓加入Delegate
@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate,UITableViewDelegate,MFMailComposeViewControllerDelegate>
{       //↓宣告變數
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
    NSString * message;
    CLLocation * selfLocation;
    NSString * parkingOfAlert ;


}
@property (strong, nonatomic) IBOutlet UIBarButtonItem *listhidden;
@property (nonatomic,strong) LLSlideMenu * slideMenu;
@property (nonatomic,strong) Reachability * reachaBility;
@property (weak, nonatomic) IBOutlet MKMapView *mainMapView;
@property (nonatomic) NSMutableArray * jsonInfo;
@property (nonatomic) CLLocationCoordinate2D targetCoordinate;
@property (nonatomic) NSString * placeName;
@property (nonatomic) NSString * name;
@property (nonatomic) MKUserLocation * userLocation;
@property (nonatomic) NSString * carSpeac;
@property (nonatomic) NSNumber * speacForAlert;
@property (nonatomic) NSNumber * motoForAlert;
@property (nonatomic) NSString * moneyFoAlert;
@end
@implementation ViewController


-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.271 green:0.286 blue:0.294 alpha:1.00],NSForegroundColorAttributeName,nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
//    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.font = [UIFont boldSystemFontOfSize:20];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.text = @"台南停車資訊";
//    self.navigationItem.titleView = titleLabel;
    
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
//
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
    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    GADRequest * request = [GADRequest request];
    
//    request.testDevices = @[@"609707ad65bcc85ee2cf9bce387d7484"];
    //↓請bannerview載入
    [self.adBannerView loadRequest:request];
    _slideMenu = [[LLSlideMenu alloc] init];
    [self.view addSubview:_slideMenu];
    
    _slideMenu.ll_menuWidth = 450.f;
    
    _slideMenu.ll_menuBackgroundColor = [UIColor colorWithRed:0.776 green:0.278 blue:0.247 alpha:0.85];
    
    _slideMenu.ll_springDamping = 20;       // 阻力
    _slideMenu.ll_springVelocity = 20;      // 速度
    _slideMenu.ll_springFramesNum = 60;     // 幀數
    
    // Get the Screen width
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat logoWidth = 80;
    CGFloat designWidth = 200;
    CGFloat inFoWidth = 260;
    CGFloat mailWidth = 260;
    
    CGFloat imageX = (screenWidth - logoWidth) / 2;
    CGFloat designX= (screenWidth - designWidth) / 2;
    CGFloat inFoX = (screenWidth - inFoWidth) / 2;
    CGFloat mailX = (screenWidth - mailWidth) / 2;
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, 100, logoWidth, 80)];
    [img setImage:[UIImage imageNamed:@"Zero.png"]];
    [_slideMenu addSubview:img];
    
    UILabel * designByMe = [[UILabel alloc]initWithFrame:CGRectMake(designX, 120, designWidth, 150)];
    designByMe.text = @"©️2016 Lin Yun Shiuan";
    //-----------------------------
    UILabel * inForLabel = [[UILabel alloc]initWithFrame:CGRectMake(inFoX, 50, inFoWidth, 500)];
    inForLabel.text = @"包含全台南「公有免費」、「公有收費」以及「民營」共177處停車場資訊（非即時）。\n停車場各處導航(Apple Map)、列表快速搜尋。";
    //-----------------------------
    UIButton *mail = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [mail addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchDown];
    [mail setTitle:@"poloa51404@gmail.com" forState:UIControlStateNormal];
    [mail setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    mail.frame = CGRectMake(mailX, 400, mailWidth, 10);
    //-----------------------------
    [inForLabel setTextColor:[UIColor colorWithRed:0.271 green:0.286 blue:0.294 alpha:1.00]];
    [designByMe setTextColor:[UIColor colorWithRed:0.271 green:0.286 blue:0.294 alpha:1.00]];
    [inForLabel setNumberOfLines:0];
    [_slideMenu addSubview:designByMe];
    [_slideMenu addSubview:inForLabel];
    [_slideMenu addSubview:mail];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark 關於我的開關判斷
- (IBAction)abm:(id)sender {
   
    if (_slideMenu.ll_isOpen) {
        [_slideMenu ll_closeSlideMenu];
        self.navigationItem.leftBarButtonItem.title = @"關於我";
        self.navigationItem.rightBarButtonItem.title = @"列表模式";
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
        
    } else {
        [_slideMenu ll_openSlideMenu];
            self.navigationItem.leftBarButtonItem.title = @"返回";
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:0.800 green:0.302 blue:0.271 alpha:1.00];
    }
}
#pragma mark 定位控制器
    //↓把切換控制器拉進來作為一個IBAction
- (IBAction)locationAndTrack:(UISegmentedControl *)sender {
    //↓給索引值一個變數名稱，索引值為整數故使用NSInteger
    NSInteger targetIndex = sender.selectedSegmentIndex;
    //↓使用切換開關來控制與設定其內容
    switch (targetIndex) {
//        case 0:
//            [self defultLocation];
//            break;
        case 0:
            self.mainMapView.userTrackingMode = MKUserTrackingModeFollow;
            break;
        case 1:
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
    selfLocation = locations.lastObject;
    //↓預設位置進入點
//    mapCenter.latitude = 22.992282;
//    mapCenter.longitude = 120.195134;
    //↓印出自己的位作為測試
    //NSLog(@"%.6f,%.6f",mapCenter.latitude,mapCenter.longitude);
    static dispatch_once_t changRegionOnceToken;
    //↓確保自己的程式碼只Run一次
    dispatch_once(&changRegionOnceToken, ^{
    
    //↓建立地圖中心跟縮放比的類別，座標區域命名然後取代主地圖
    MKCoordinateRegion regoin = self.mainMapView.region;
    //↓使用regoin來定位中心
    regoin.center = selfLocation.coordinate;
    //↓地圖中心的經緯度縮放比
    regoin.span.latitudeDelta = 0.01;
    regoin.span.longitudeDelta= 0.01;
    //↓設定動畫在主畫面顯示方法
    [self.mainMapView setRegion:regoin animated:true];
    firstLocationReceived = true;
    });
}
#pragma mark 按下大頭針並且拉近
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{

    [self getPinLocation];
//    mapCenter.latitude = 0;
//    mapCenter.longitude= 0;
    MKCoordinateRegion regoin = self.mainMapView.region;
    regoin.center = _targetCoordinate;
    regoin.span.latitudeDelta = 0.01;
    regoin.span.longitudeDelta= 0.01;
    [self.mainMapView setRegion:regoin animated:true];
    firstLocationReceived = true;
    _mainMapView.userLocation.title = @"目前位置";
    
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
-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(nonnull id <MKAnnotation>)annotation {
    if (annotation ==mV.userLocation) {
        return nil;
    }
    static NSString * defaultPinID = @"Pin";
    MKAnnotationView *pinView = (MKPinAnnotationView*)[self.mainMapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if(pinView == nil)
    {
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID] ;
    }
    UIImage * annotationImage = [UIImage imageNamed:@"LocationPin.png"];
    pinView.image = annotationImage;
#pragma mark ℹ︎按鈕
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [detailButton addTarget:self action:@selector(addToListButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    detailButton.center = CGPointZero;
    pinView.rightCalloutAccessoryView = detailButton;
    

    
//    pinView.animatesDrop = false;
    pinView.canShowCallout = YES;
    [pinView setSelected:YES animated:YES];
    
    
    return pinView;
    
}
#pragma mark alert按鈕
-(void)addToListButtonTapped:(id)sender
{
    [self getPinLocation];
    NSString * forAlert = parkingOfAlert;
    //↓表格框的title文字
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:_placeName message:forAlert preferredStyle:UIAlertControllerStyleAlert];
    
    
    //↓設定按鈕1還有設定按鈕1進入導航功能
    UIAlertAction * navigationBT = [UIAlertAction actionWithTitle:@"導航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self getPinLocation];
        MKPlacemark * place = [[MKPlacemark alloc]initWithCoordinate:self.targetCoordinate addressDictionary:nil];
        
//        NSString * stringURLContent = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@&saddr=%@",place,selfLocation];
        
        
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
                _speacForAlert = [onelist objectForKey:@"小型車(一般)"];
                _motoForAlert = [onelist objectForKey:@"機車(一般)"];
                _moneyFoAlert = [onelist objectForKey:@"收費費率"];
                
                NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
                NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
                NSString * parkingSpeacToCell= [onelist objectForKey:@"小型車(一般)"];
                NSString * parkingMotoSpeacToCell = [onelist objectForKey:@"機車(一般)"];
                parkingMoneyToCell = [_moneyFoAlert stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                
                [parkingSpeac addObject:parkingSpeacToCell];
                [parkingName addObject:forTableCell];
                [parkingCarMoney addObject:parkingMoneyToCell];
                [parkingMotoSpeac addObject:parkingMotoSpeacToCell];
                [parkingLocationX addObject:locationX];
                [parkingLocationY addObject:locationY];
                
                
                point = [MKPointAnnotation new];
                point.coordinate = LocationCoordinates;
                point.title = _name;
                point.subtitle = [NSString stringWithFormat:@"汽車位:%@" "機車位:%@" "價格:%@",_speacForAlert,_motoForAlert,parkingMoneyToCell];
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
                _speacForAlert = [onelist objectForKey:@"小型車(一般)"];
                _motoForAlert = [onelist objectForKey:@"機車(一般)"];
                _moneyFoAlert = [onelist objectForKey:@"收費費率"];
            if ([onelist valueForKey:@"收費費率"] == [NSNull null]) {
                _moneyFoAlert = [NSString stringWithFormat:@"免費"];
            }
                NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
                NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
            if ([onelist valueForKey:@"收費費率"] == [NSNull null]) {
                parkingMoneyToCell = [NSString stringWithFormat:@"價格:%@",_moneyFoAlert];
            }
                NSString * parkingSpeacToCell= [onelist objectForKey:@"小型車(一般)"];
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
                point.subtitle = [NSString stringWithFormat:@"汽車位:%@" "機車位:%@" "價格:%@",_speacForAlert,_motoForAlert,_moneyFoAlert];
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
            _speacForAlert = [onelist objectForKey:@"小型車(一般)"];
            _motoForAlert = [onelist objectForKey:@"機車(一般)"];
            _moneyFoAlert = [onelist objectForKey:@"收費費率"];
            if ([onelist valueForKey:@"收費費率"] == [NSNull null]) {
            _moneyFoAlert = [NSString stringWithFormat:@"無提供資訊"];
            }
    
            NSString * forTableCell = [onelist objectForKey:@"停車場名稱"];
            NSString * parkingMoneyToCell = [onelist objectForKey:@"收費費率"];
            if ([onelist valueForKey:@"收費費率"] == [NSNull null]) {
            parkingMoneyToCell = [NSString stringWithFormat:@"價格:%@",_moneyFoAlert];
            }
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
            point.subtitle = [NSString stringWithFormat:@"汽車位:%@" "機車位:%@""價格:%@",_speacForAlert,_motoForAlert,_moneyFoAlert];
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
        parkingOfAlert = pin.subtitle;
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
    
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] init];
    backButtonItem.title = @"回地圖模式";
    self.navigationItem.backBarButtonItem = backButtonItem;
    
}

#pragma mark 網路狀態改變時vc會得到通知
-(void)networkReachabilityChanged:(NSNotification *)note{
    Reachability * curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        
    }
}
#pragma mark 郵件內容設定
- (void)send:(id)sender {
    MFMailComposeViewController *comp=[[MFMailComposeViewController alloc]init];
    [comp setMailComposeDelegate:self];
    if([MFMailComposeViewController canSendMail]) {
        [comp setToRecipients:[NSArray arrayWithObjects:@"poloa51404@gmail.com", nil]];
//        [comp setSubject:@""];
//        [comp setMessageBody:@"" isHTML:NO];
        [comp setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [self presentViewController:comp animated:YES completion:nil];
    }
    else {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alrt show];
    }
}
#pragma mark 郵件控制器
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if(error) {
        UIAlertView *alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"" delegate:nil cancelButtonTitle:@"" otherButtonTitles:nil, nil];
        [alrt show];
        [self dismissModalViewControllerAnimated:YES];
    }
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}
@end
