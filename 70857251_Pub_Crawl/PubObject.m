//
//  PubObject.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PubObject.h"

// This is the Pub Annotation object
// It has the co-ordinates of the pub along with the pubs name and address
@implementation PubObject

@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;

- (id)initWithName:(NSString *)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else {
        return _name;
    }
}

- (NSString *)subtitle {
    return _address;
}

@end
