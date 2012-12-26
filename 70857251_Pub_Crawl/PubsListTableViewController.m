//
//  PubsListTableViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PubsListTableViewController.h"
#import "ViewController.h"
#import "SBJson.h"
#import "GTMNSString+URLArguments.h"
#import "GooglePlacesObject.h"
#import "MessageUI/MessageUI.h"
#import "LocationObject.h"
#import "MBProgressHUD.h"
#import "PubDetailViewController.h"

@interface PubsListTableViewController ()

@end

@implementation PubsListTableViewController

@synthesize resultsLoaded;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize urlConnection;
@synthesize responseData;
@synthesize locations;
//NEW - to handle filtering
@synthesize locationsFilterResults;
@synthesize tableView;
@synthesize reference;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    responseData = [[NSMutableData data] init];
    
    // Pull the address from the location singleton
	LocationObject* sharedLocation = [LocationObject sharedManager];
    NSMutableString *usersAddress = [sharedLocation address];
    
    // If we have an address then we don't want to use the users current location
    if (usersAddress.length < 1)
    {
        [[self locationManager] startUpdatingLocation];
    }
    
    [tableView reloadData];
    [tableView setContentOffset:CGPointZero animated:NO];
    
    // Initialize a new google places connection
    googlePlacesConnection = [[GooglePlacesConnection alloc] initWithDelegate:self];
    
    // If we have an addressCall the getGoogleObjects method - we'll be getting the coordinates
    // for the address in the googlePlacesConnection so we'll just pass dummy coordinates
    if (usersAddress.length > 0)
    {
        //What places to search for - for pub crawls we're just looking for bars and nightclubs
        NSString *searchLocations = [NSString stringWithFormat:@"%@|%@", 
                                     kBar,
                                     kNightClub
                                     ];
        
        [googlePlacesConnection getGoogleObjects:CLLocationCoordinate2DMake(0.0, 0.0) 
                                    andTypes:searchLocations];
    }
    
    // Create and initialize a new progress bar
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading nearby Pubs...";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self setUrlConnection:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSUInteger)arrayIndexFromIndexPath:(NSIndexPath *)path 
{
    return path.row;
}

#pragma mark -
#pragma mark PullToRefresh

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [locationsFilterResults count];
}

// Reloads the datasource based on location changed
- (void)reloadTableViewDataSource
{
    [self setResultsLoaded:NO];
    
    // Called when the location changes
    [[self locationManager] startUpdatingLocation];
    
	[super performSelector:@selector(dataSourceDidFinishLoadingNewData) withObject:nil afterDelay:3.0];
}

// Called after the datasource has finished loading
- (void)dataSourceDidFinishLoadingNewData{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
}

#pragma mark -
#pragma mark Table view data source

//UPDATE - to handle filtering
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"LocationCell";
	
	// Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell                = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Get the object to display and set the value in the cell.    
    GooglePlacesObject *place     = [[GooglePlacesObject alloc] init];
    
    //UPDATED from locations to locationFilter results
    place                       = [locationsFilterResults objectAtIndex:[indexPath row]];
    
    cell.textLabel.text                         = place.name;
    cell.textLabel.adjustsFontSizeToFitWidth    = YES;
	cell.textLabel.font                         = [UIFont systemFontOfSize:12.0];
	cell.textLabel.minimumFontSize              = 10;
	cell.textLabel.numberOfLines                = 4;
	cell.textLabel.lineBreakMode                = UILineBreakModeWordWrap;
    cell.textLabel.textColor                    = [UIColor colorWithRed:0.0 green:128.0/255.0 blue:0.0 alpha:1.0];
    cell.textLabel.textAlignment                = UITextAlignmentLeft;
    
    //You can use place.distanceInMilesString or place.distanceInFeetString.  
    //You can add logic that if distanceInMilesString starts with a 0. then use Feet otherwise use Miles.
    cell.detailTextLabel.text                   = [NSString stringWithFormat:@"%@ - Distance %@ miles", place.vicinity, place.distanceInMilesString];
    cell.detailTextLabel.textColor              = [UIColor darkGrayColor];
    cell.detailTextLabel.font                   = [UIFont systemFontOfSize:10.0];
    
    return cell;
}

// Before invoking the pub details controller we want to pass a reference to the selected row
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowPubDetail"]) 
    {        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        
        //UPDATED from locations to locationFilterResults
        GooglePlacesObject *places = [locationsFilterResults objectAtIndex:selectedRowIndex.row];
        
        PubDetailViewController *pubDetailViewController = [segue destinationViewController];
        pubDetailViewController.reference =  places.reference;
    }
}

#pragma mark -
#pragma mark Location manager

/**
 Return a location manager -- create one only if necessary.
 */
- (CLLocationManager *)locationManager 
{
	
    if (locationManager != nil) 
    {
		return locationManager;
	}
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[locationManager setDelegate:self];
	
	return locationManager;
}


/**
 Conditionally enable the Add button:
 If the location manager is generating updates, then enable the button;
 If the location manager is failing, then disable the button.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation 
{
    // Pull the address from the location singleton
	LocationObject* sharedLocation = [LocationObject sharedManager];
    NSMutableString *usersAddress = [sharedLocation address];
    
    // If we have an address then we don't care if the devices location is changing
    if (usersAddress.length < 1)
    {
        // Update the currentLocation variable so it matches what's been sent to google places
        currentLocation = newLocation;
    }
    
    if ([self isResultsLoaded]) 
    {
        return;
    }
    
    [self setResultsLoaded:YES];
    
    
    //What places to search for - for pub crawls we're just looking for bars and nightclubs
    NSString *searchLocations = [NSString stringWithFormat:@"%@|%@", 
                                     kBar,
                                     kNightClub
                                     ];
    
    // Call the getGoogleObjects method which will look for any pubs near the location created by the location manager
    [googlePlacesConnection getGoogleObjects:CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude) 
                                    andTypes:searchLocations];
    
}

// Call back for when the location manager fails
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error 
{
    NSLog(@"locationManager FAIL");
    NSLog(@"%@", [error description]);
}

#pragma mark -
#pragma mark NSURLConnections

// Callback for when the google places search returns
- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)objects 
{
    // Clear the progress bar
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Check if there were any pubs found near the location
    if ([objects count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" 
                                                        message:@"Try another address" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        locations = objects;
        // Add the list of pubs to the location singleton
        LocationObject* sharedLocation = [LocationObject sharedManager];
        [[sharedLocation pubs] setArray:[objects mutableCopy]];  
        //UPDATED locationFilterResults for filtering later on
        locationsFilterResults = objects;
        // Reload the tableview
        [tableView reloadData];
    }
}

// Callback for when the google places call results in an error
- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error
{
    // Clear the progress bar
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Tell the user the error that occurred
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" 
                                                    message:[error localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
}

// Generate the email with the list of pubs in the crawl
- (IBAction)uploadPhotos:(id)sender
{
    // Create a new email view controller
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // Set the email subject
    [picker setSubject:@"Pub Crawl"];
    
    // Retrieve the list of pubs from the location singleton
    LocationObject* sharedLocation = [LocationObject sharedManager];
    NSMutableArray *pubLocations = [sharedLocation pubs];
    
    // Set the email body
    NSMutableString *emailBody = [NSMutableString stringWithString:@"Pub Crawl Route"];
    
    // Add each pubs details to the email
    for (int i=0; i<pubLocations.count; i++) {
        
        // Cast the pub to a GooglePlacesObject
        GooglePlacesObject *place = [[GooglePlacesObject alloc] init];
        place = [pubLocations objectAtIndex:i];
        
        // Create a newline string
        NSString *newline = @"\n";
        [emailBody appendString:newline];
        
        // Retrieve the pubs name and add it to the email if it's not nil
        NSString *pubName = place.name;
        if (pubName != Nil) {
            [emailBody appendString:pubName];
            [emailBody appendString:newline];
        }
        
        // Retrieve the pubs address and add it to the email if it's not nil
        NSString *pubAddress = place.formattedAddress;
        if (pubAddress != Nil) {
            [emailBody appendString:@"Address: "];
            [emailBody appendString:pubAddress];
            [emailBody appendString:newline];
        }
        
        // Retrieve the pubs phone number and add it to the email if it's not nil
        NSString *pubNumber = place.formattedPhoneNumber;
        if (pubNumber != Nil) {
            [emailBody appendString:@"Ph Num: "];
            [emailBody appendString:pubNumber];
            [emailBody appendString:newline];
        }
        
        // Retrieve the pubs website and add it to the email if it's not nil
        NSString *pubWebsite = place.website;
        if (pubWebsite != Nil) {
            [emailBody appendString:@"Website: "];
            [emailBody appendString:pubWebsite];
            [emailBody appendString:newline];
        }
        [emailBody appendString:newline];
    }
    
    
    // Set the message body and launch the email view
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentModalViewController:picker animated:YES];
}

// Email result handler
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
{
    // Dismiss the mail view
    if (result == MFMailComposeResultSent) {
        NSLog(@"Mail sent successfully");
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end