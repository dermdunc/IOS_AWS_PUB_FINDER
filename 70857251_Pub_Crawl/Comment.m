//
//  Comment.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import "Comment.h"

@implementation Comment

@synthesize pub;
@synthesize comment;

-(id)initWithPub:(NSString *)thePub andComment:(NSString *)theComment
{
    self = [super init];
    if (self)
    {
        pub = thePub;
        comment  = theComment;
    }
    
    return self;
}

@end
