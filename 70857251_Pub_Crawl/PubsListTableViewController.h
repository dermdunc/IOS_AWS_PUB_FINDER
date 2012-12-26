//
//  PubsListTableViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GooglePlacesConnection.h"
#import "MessageUI/MessageUI.h"

@class GooglePlacesObject;
@class ViewController;

@interface PubsListTableViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GooglePlacesConnectionDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>
{   
    CLLocationManager       *locationManager;
    CLLocation              *currentLocation;
    
    NSMutableData           *responseData;
    NSMutableArray          *locations;
    NSMutableArray          *locationsFilterResults;
    NSString                *searchString;
    
    GooglePlacesConnection  *googlePlacesConnection;
    UITableView         *tableView;
}

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, getter = isResultsLoaded) BOOL resultsLoaded;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation        *currentLocation;

@property (nonatomic, retain) NSURLConnection   *urlConnection;
@property (nonatomic, retain) NSMutableData     *responseData;
@property (nonatomic, retain) NSMutableArray    *locations;
@property (nonatomic, retain) NSMutableArray    *locationsFilterResults;

-(IBAction)uploadPhotos:(id)sender;

@end

