//
//  PubDetailViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PubDetailViewController.h"

#import "GooglePlacesObject.h"
#import "PhotoUploaderViewController.h"
#import "PubPhotosViewController.h"
#import "ShowCommentsViewController.h"
#import "Comment.h"
#import "CommentList.h"

@implementation PubDetailViewController

@synthesize placeName = _placeName;
@synthesize placeFormattedAddress = _placeFormattedAddress;
@synthesize placePhoneNumber = _placePhoneNumber;
@synthesize placeRating = _placeRating;
@synthesize placeWebsite = _placeWebsite;
@synthesize reference = _reference;
@synthesize place = _place;
@synthesize commentText = _commentText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize the googlePlacesConnection object and get the pubs details
    googlePlacesConnection = [[GooglePlacesConnection alloc] initWithDelegate:self];
    [googlePlacesConnection getGoogleObjectDetails:_reference];
    
}


- (void)viewDidUnload
{
    [self setCommentText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Before invoking the pub details controller we want to pass a reference to the selected row
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
    NSString *resultString = [[_place.name componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    
    if ([[segue identifier] isEqualToString:@"PhotoUploader"])
    {
        PhotoUploaderViewController *photoUploaderViewController = [segue destinationViewController];
        photoUploaderViewController.reference  = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else if ([[segue identifier] isEqualToString:@"PhotoViewer"])
    {
        PubPhotosViewController *pubPhotosViewController = [segue destinationViewController];
        pubPhotosViewController.reference  = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else if ([[segue identifier] isEqualToString:@"CommentsViewer"])
    {
        ShowCommentsViewController *showCommentsViewController = [segue destinationViewController];
        showCommentsViewController.reference  = [resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

-(void)loadViewWithGooglePlaces:(NSMutableArray *)objects 
{
    // Make sure some object was returned
    if (objects.count > 0)
    {
        // Parse the object to a googlePlacesObject
        _place = [objects objectAtIndex:0];
    
        // Pull all the values from the GooglePlacesobject and push them to the GUI
        if (_place.name != Nil) {
            [_placeName setText:_place.name];
        }
        if (_place.formattedAddress != Nil) {
            [_placeFormattedAddress setText:_place.formattedAddress];
        }
        if (_place.formattedPhoneNumber != Nil) {
            [_placePhoneNumber setText:_place.formattedPhoneNumber];
        }
        if (_place.website != Nil) {
            [_placeWebsite setText:_place.website];
        }
        if (_place.rating != Nil) {
            // Rating is a decimal so needs to be cast to a string
            NSString *temp = 
            [NSString stringWithFormat:@"%@", _place.rating];
            [_placeRating setText:temp];
        }
    }
    
}

-(IBAction) commentBtnPushed:(id)sender {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        // Strip all special characters and whitespace from pub name. These are not allowed in sinpledDB names
        NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        NSString *resultString = [[_place.name componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
        
        // Create a new comment object
        Comment *comment     = [[Comment alloc] initWithPub:[resultString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] andComment:[_commentText text]];
        
        // Initialize the commentList object and check if the comments simpleDB exists
        // If not then create it
        CommentList *commentList = [[CommentList alloc] init];
        if (![commentList checkIfCommentsDomainExists])
            [commentList createCommentsDomain];
    
        // Upload the comment to the simpleDB
        [commentList addComment:comment];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            [self dismissModalViewControllerAnimated:YES];
        });
    });
}

// Remove the keyboard each time the users clicks out of a textfield
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_commentText resignFirstResponder];
}

#pragma mark -
#pragma mark NSURLConnections

- (void)googlePlacesConnection:(GooglePlacesConnection *)conn didFinishLoadingWithGooglePlacesObjects:(NSMutableArray *)objects 
{
    // If no objects were returned let the user know
    if ([objects count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" 
                                                        message:@"Try another place name or address" 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        // Otherwise update the UI
        [self   loadViewWithGooglePlaces:objects];
    }
}

- (void) googlePlacesConnection:(GooglePlacesConnection *)conn didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" 
                                                    message:[error localizedDescription] 
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles: nil];
    [alert show];
}

@end
