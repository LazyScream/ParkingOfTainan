//
//  MyTableViewController.m
//  ParkingOfTaiwan
//
//  Created by LazyScream on 2016/6/3.
//  Copyright © 2016年 LazyScream. All rights reserved.
//

#import "MyTableViewController.h"
#import "MyTableViewCell.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface MyTableViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate>


@property(strong,nonatomic)NSMutableArray * searchResult;
@property (nonatomic) NSMutableArray * nameResult;
@property (nonatomic,retain) UISearchController *searchController;
@property (nonatomic) NSMutableString * message;
@end

@implementation MyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    //_searchController.searchBar.barTintColor = [UIColor magentaColor];
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    self.nameResult = [NSMutableArray arrayWithArray:self.allNameList];
    self.tableView.tableHeaderView = self.searchController.searchBar; self.definesPresentationContext = YES;
    self.searchResult =self.nameResult;
    
    [self.searchController.navigationController setNavigationBarHidden:false animated:false];
    
    //[self.tableView setContentOffset:CGPointMake(0, self.searchController.searchBar.frame.size.height)];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    
    return self.searchResult.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.cellBakcGround.image = [UIImage imageNamed:[NSString stringWithFormat:@"Background %li.png", indexPath.row%15 + 1]];
    cell.ParkingName.text = self.searchResult[indexPath.row];
            return cell;
}
    //↓更新搜尋結果到搜尋控制器
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@", self.searchController.searchBar.text];
       
    self.searchResult = [NSMutableArray arrayWithArray:
                [self.nameResult filteredArrayUsingPredicate:searchPredicate]];
    
    
    //↓清除搜尋框後把原本列表拿回來
    if (self.searchController.searchBar.text.length==0) {
        self.searchResult=self.nameResult;
    }
    
    
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = [indexPath row];
    NSString *parkingOfName = [self.searchResult objectAtIndex:row];
    NSInteger index;
    index = [self.nameResult indexOfObject:parkingOfName];
    NSString *parkingOfCarSpeac =[self.PKCarSpeac objectAtIndex:index];
    NSString *parkingOfMoney =[self.PKMoney objectAtIndex:index];
    NSString *parkingOfMotoSpeac=[self.PKMotoSpeac objectAtIndex:index];
    NSString *parkingOfLocationX=[self.PKLocationX objectAtIndex:index];
    NSString *parkingOfLocationY=[self.PKLocationY objectAtIndex:index];
    
    self.message= [[NSMutableString alloc] initWithFormat:
    @"%@\n價格:%@\n汽車位:%@\n機車位:%@",parkingOfName,parkingOfMoney,parkingOfCarSpeac,parkingOfMotoSpeac];
    
    UIAlertController * alert =[UIAlertController alertControllerWithTitle:@"停車資訊" message:_message preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * navigationBT =[UIAlertAction actionWithTitle:@"導航" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CLLocationCoordinate2D liAndlo;
        liAndlo.latitude = parkingOfLocationX.floatValue;
        liAndlo.longitude= parkingOfLocationY.floatValue;
        MKPlacemark * place = [[MKPlacemark alloc]initWithCoordinate:liAndlo addressDictionary:nil];
        [self openMap:place];
        
    }];
    UIAlertAction * canCelBT = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:navigationBT];
    [alert addAction:canCelBT];
    [self presentViewController:alert animated:true completion:nil];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
    
    
}
#pragma marl 開啟地圖
-(void)openMap:(CLPlacemark*)targetPlacemark{
    MKPlacemark * place = [[MKPlacemark alloc]initWithPlacemark:targetPlacemark];
    MKMapItem * mapItem = [[MKMapItem alloc]initWithPlacemark:place];
    NSDictionary * options = @{
    MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
    };
    [mapItem openInMapsWithLaunchOptions:options];
}

-(void)getLocationToMap{
    
}
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    Return NO if you do not want the specified item to be editable.
//    return YES;
//}



// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [self.tmp removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
