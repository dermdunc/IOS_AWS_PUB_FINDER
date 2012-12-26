//
//  Comment.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject {
    NSString *pub;
    NSString *comment;
}

@property (nonatomic, readonly) NSString *pub;
@property (nonatomic, readonly) NSString *comment;


-(id)initWithPub:(NSString *)thePub andComment:(NSString *)theComment;

@end
