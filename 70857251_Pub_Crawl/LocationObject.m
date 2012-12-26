//
//  LocationObject.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LocationObject.h"

// Singleton Object which holds the main locations longitude and latitude
// Also holds the address if one is specified. This is an empty string if we're using the current location
// Also holds an array of pub objects
static LocationObject *sharedLocationObject = nil;

@implementation LocationObject

@synthesize address;
@synthesize latitude;
@synthesize longitude;
@synthesize pubs;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedLocationObject == nil)
            sharedLocationObject = [[self alloc] init];
    }
    return sharedLocationObject;
}

- (id)init {
    if (self = [super init]) {
        address = [NSMutableString stringWithString:@""];
        latitude = [NSMutableString stringWithString:@"0"];
        longitude = [NSMutableString stringWithString:@"0"];
        pubs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never get called
}

@end
