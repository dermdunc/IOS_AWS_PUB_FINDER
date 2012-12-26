//
//  LocationObject.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationObject : NSObject
{
    NSMutableString* address;
    NSMutableString* latitude;
    NSMutableString* longitude;
    NSMutableArray* pubs;
}

@property (nonatomic, copy) NSMutableString* address;
@property (nonatomic, copy) NSMutableString* latitude;
@property (nonatomic, copy) NSMutableString* longitude;
@property (nonatomic, copy) NSMutableArray* pubs;
+ (id)sharedManager;

@end
