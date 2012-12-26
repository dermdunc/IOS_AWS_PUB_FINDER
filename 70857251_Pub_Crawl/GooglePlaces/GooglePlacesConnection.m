//
//  GooglePlacesConnection.m
// 
// Copyright 2011 Joshua Drew
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//  70857251_Pub_Crawl
//
//  Updated by Dermot Duncan on 4/25/12.

#import "GooglePlacesConnection.h"
#import "../GTM/GTMNSString+URLArguments.h"
#import "LocationObject.h"

@implementation GooglePlacesConnection

@synthesize delegate;
@synthesize responseData;
@synthesize connection;
@synthesize connectionIsActive;
@synthesize minAccuracyValue;
//NEW
@synthesize userLocation;

- (id)initWithDelegate:(id <GooglePlacesConnectionDelegate>)del
{
	self = [super init];
	
	if (!self)
		return nil;
	[self setDelegate:del];	
	return self;
}

- (id) init
{
	NSLog(@"need a delegate!! use initWithDelegate!");
	return nil;
}

// Method called if the user specifies a location
- (void)getSpecifiedLocation:(NSMutableString *)address andTypes:(NSString *)types
{
    // Initialize a new geocoder object to forward geocode based on an address passed in
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    // Declare a handler which will be called when the geocoder returns
    CLGeocodeCompletionHandler completionHandler = 
    ^(NSArray *placemarks, NSError *error)
    {
        // Check to see if the geocoder was able to find any values for the address
        if ([placemarks count] > 0)
        {
            // Note possible bug here. We just use the first placemark returned by the geocoder.
            // This may not neccessarily be the location the user is looking for if more than one location
            // matches the search request
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            [self getGoogleObjectResults:location.coordinate andTypes:types];
            
            NSLog(@"Found placemark: %@", placemark);
        }
        // If no results were found let the user know they need to specify a different or more complete address
        else 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Address" 
                                                            message:@"Google was unable to find this address. Please re-enter a valid address." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles: nil];
            [alert show];
        }
    };
    
    // Assuming a valid address call the geocoder
    // Note enhancement would be to check for special characters in the address and either strip them out
    // or throw an error
    if (address.length > 0) 
    {
        [geocoder geocodeAddressString:address completionHandler:completionHandler];
    }
    // If the user has entered no address than tell them to enter something if they wish to search by address
    else 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Empty Address" 
                                                        message:@"Please enter a valid address." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
        [alert show];
    }
}

//Method is called to load initial search
-(void)getGoogleObjects:(CLLocationCoordinate2D)coords andTypes:(NSString *)types
{
    // Pull the address from the location singleton
	LocationObject* sharedLocation = [LocationObject sharedManager];
    NSMutableString *usersAddress = [sharedLocation address];
    
    // If we have an address then we want to search for pubs based on the address specified
    if (usersAddress.length > 0)
    {
        [self getSpecifiedLocation:usersAddress andTypes:types];
    }
    // Otherwise we use the users current location
    else 
    {
        [self getGoogleObjectResults:coords andTypes:types];
    }
    
    
}

// The meat of the above method which gets the pubs list
-(void)getGoogleObjectResults:(CLLocationCoordinate2D)coords andTypes:(NSString *)types
{
    //NEW setting userlocation to the coords passed in for later use
    userLocation = coords;
    
    // Pull the location singleton and update the long and lat values in it to be the current coordinates
    LocationObject* sharedLocation = [LocationObject sharedManager];
    [[sharedLocation longitude]  setString:[NSMutableString stringWithFormat:@"%f", coords.longitude]];
    [[sharedLocation latitude]  setString:[NSMutableString stringWithFormat:@"%f", coords.latitude]];
    
    double centerLat = coords.latitude;
	double centerLng = coords.longitude;
    
    // Get the types of places we're searching for
    // For the pub crawler we're currently just looking for bars and nightclubs
    types = [types gtm_stringByEscapingForURLArgument];
    
    // Create the google places url which will return a JSON result
    NSString* gurl  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=2000&types=%@&sensor=true&key=%@",
                       centerLat, centerLng, types, kGOOGLE_API_KEY];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:gurl] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                       timeoutInterval:500];
    
    // Close the google connection
	[self cancelGetGoogleObjects];
	
    // Create a new connection object with the google places request created above
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (connection) 
    {
		responseData = [NSMutableData data];
		connectionIsActive = YES;
	}		
	else {
        NSLog(@"connection failed");
	}
    
    
}

//Method is called to get details of place
-(void)getGoogleObjectDetails:(NSString *)reference
{	
    
    NSString* gurl  = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@",
                       reference, kGOOGLE_API_KEY];
    
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:gurl] 
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                                       timeoutInterval:10];
    
	[self cancelGetGoogleObjects];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
	if (connection) 
    {
		responseData = [NSMutableData data];
		connectionIsActive = YES;
	}		
	else {
        NSLog(@"connection failed");
	}
    
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response 
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data 
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error 
{
	connectionIsActive = NO;
	[delegate googlePlacesConnection:self didFailWithError:error];
}

// We got a result from the places search so time to parse it into usable data
- (void)connectionDidFinishLoading:(NSURLConnection *)conn 
{
    connectionIsActive          = NO;

    // Create a dictionary from the JSON response
    SBJsonParser *json          = [[SBJsonParser alloc] init];
	NSString *responseString    = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];	
	NSError *jsonError          = nil;
	NSDictionary *parsedJSON    = [json objectWithString:responseString error:&jsonError];
    
    // Check that we didn't get an error
	if ([jsonError code]==0) 
    {
        // Pull the response status from the JSON dictionary
        NSString *responseStatus = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"status"]];
    
        if ([responseStatus isEqualToString:@"OK"]) 
        {
            // Check if there are any records in the JSON results
            if ([parsedJSON objectForKey: @"results"] == nil) {
                //Perform Place Details results
                NSDictionary *gResponseDetailData = [parsedJSON objectForKey: @"result"];
                NSMutableArray *googlePlacesDetailObject = [NSMutableArray arrayWithCapacity:1];  //Hard code since ONLY 1 result will be coming back
                
                GooglePlacesObject *detailObject = [[GooglePlacesObject alloc] initWithJsonResultDict:gResponseDetailData andUserCoordinates:userLocation];
                [googlePlacesDetailObject addObject:detailObject];
                
                [delegate googlePlacesConnection:self didFinishLoadingWithGooglePlacesObjects:googlePlacesDetailObject];
                
            } else {
                //Perform Place Search results
                NSDictionary *gResponseData  = [parsedJSON objectForKey: @"results"];
                NSMutableArray *googlePlacesObjects = [NSMutableArray arrayWithCapacity:[[parsedJSON objectForKey:@"results"] count]]; 

                // Add each pub to the parsed results array
                for (NSDictionary *result in gResponseData) 
                {
                    [googlePlacesObjects addObject:result];
                }
                
                // Next parse the results into googlePlacesObjects before returning them
                for (int x=0; x<[googlePlacesObjects count]; x++) 
                {                
                    GooglePlacesObject *object = [[GooglePlacesObject alloc] initWithJsonResultDict:[googlePlacesObjects objectAtIndex:x] andUserCoordinates:userLocation];
                    [googlePlacesObjects replaceObjectAtIndex:x withObject:object];
                }
                
                [delegate googlePlacesConnection:self didFinishLoadingWithGooglePlacesObjects:googlePlacesObjects];
                
            }
                        
        }
        // We got no results so generate an error
        else if ([responseStatus isEqualToString:@"ZERO_RESULTS"]) 
        {
            NSString *description = nil;
            int errCode;
            
            description = NSLocalizedString(@"No pubs found near this address.", @"");
            errCode = 404;
            
            // Make underlying error.
            NSError *underlyingError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                   code:errno userInfo:nil];
            // Make and return custom domain error.
            NSArray *objArray = [NSArray arrayWithObjects:description, underlyingError, nil];
            NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey,
                                 NSUnderlyingErrorKey, nil];
            NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray
                                                              forKeys:keyArray];
            
            NSError *responseError = [NSError errorWithDomain:@"GoogleLocalObjectDomain" 
                                                         code:errCode 
                                                     userInfo:eDict];
            
            [delegate googlePlacesConnection:self didFailWithError:responseError];
        } else {
            // no results
            NSString *responseDetails = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"status"]];
            NSError *responseError = [NSError errorWithDomain:@"GoogleLocalObjectDomain" 
                                                         code:500 
                                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:responseDetails,@"NSLocalizedDescriptionKey",nil]];
            
            [delegate googlePlacesConnection:self didFailWithError:responseError];
        }
	}
	else 
    {
		[delegate googlePlacesConnection:self didFailWithError:jsonError];
	}
	
}

- (void)cancelGetGoogleObjects 
{
	if (connectionIsActive == YES) {
		connectionIsActive = NO;
	}
}
@end
