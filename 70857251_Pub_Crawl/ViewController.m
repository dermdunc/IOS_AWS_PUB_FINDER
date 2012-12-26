//
//  ViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LocationObject.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize streetField = _streetField;
@synthesize cityField = _cityField;
@synthesize countryField = _countryField;
@synthesize stateField = _stateField;
@synthesize zipCodeField = _zipCodeField;
@synthesize addressTypeField = _addressTypeField;
@synthesize address = _address;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // By default we'll use the users location so disable all the textfields
    _streetField.enabled = false;
    _cityField.enabled = false;
    _stateField.enabled = false;
    _countryField.enabled = false;
    _zipCodeField.enabled = false;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Control used to decide if the user wants to use their current location
// or specify an address to search for
-(IBAction) segmentedControlIndexChanged{
    LocationObject* sharedLocation = [LocationObject sharedManager];
    switch (_addressTypeField.selectedSegmentIndex) {
        case 0:
            // If the user is using their current location then disable and clear all
            // the textfields
            _streetField.enabled = false;
            [_streetField setText:nil];
            _cityField.enabled = false;
            [_cityField setText:nil];
            _stateField.enabled = false;
            [_stateField setText:nil];
            _countryField.enabled = false;
            [_countryField setText:nil];
            _zipCodeField.enabled = false;
            [_zipCodeField setText:nil];
            
            // Update the address in the singleton location to be an emptystring
            _address = [NSMutableString stringWithString:@""];
            [[sharedLocation address] setString:[NSMutableString stringWithString:_address]];
            break;
        case 1:
            // If the user wants to specify an address than enable all the textfields
            _streetField.enabled = true;
            _cityField.enabled = true;
            _stateField.enabled = true;
            _countryField.enabled = true;
            _zipCodeField.enabled = true;
            break;
        default:
            break;
    }
}

// Remove the keyboard each time the users clicks out of a textfield
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_streetField resignFirstResponder];
    [_cityField resignFirstResponder];
    [_stateField resignFirstResponder];
    [_countryField resignFirstResponder];
    [_zipCodeField resignFirstResponder];
    [self updateAddress];
}

// Updates the address the user wishes to finds pubs near
// called each time the user changes any of the address fields
-(void)updateAddress
{
    // Reset the address string to empty
    _address = [NSMutableString stringWithString:@""];
    
    // Check each field to see if it has a value.
    // If it does append it to the address string
    if (_streetField.text.length > 0)
        [_address appendString:_streetField.text];
    
    if (_cityField.text.length > 0)
    {
        [_address appendString:@" "];
        [_address appendString:_cityField.text];
    }
    
    if (_stateField.text.length > 0)
    {
        [_address appendString:@" "];
        [_address appendString:_stateField.text];
    }
    
    if (_countryField.text.length > 0)
    {
        [_address appendString:@" "];
        [_address appendString:_countryField.text];
    }
    
    if (_zipCodeField.text.length > 0)
    {
        [_address appendString:@" "];
        [_address appendString:_zipCodeField.text];
    }
    
    // Update the address field in the location singleton object with the new address
    LocationObject* sharedLocation = [LocationObject sharedManager];
    [[sharedLocation address] setString:[NSMutableString stringWithString:_address]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
