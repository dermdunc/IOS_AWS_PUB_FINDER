//
//  CommentList.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import <Foundation/Foundation.h>
#import <AWSiOSSDK/SimpleDB/AmazonSimpleDBClient.h>
#import "Comment.h"

@interface CommentList : NSObject {
    AmazonSimpleDBClient *sdbClient;
    NSString             *nextToken;
    int                  sortMethod;
}

@property (nonatomic, retain) NSString *nextToken;
@property (nonatomic, retain) NSString *pub;

-(int)commentCount;
-(NSArray *)getComments;
-(NSArray *)getNextPageOfComments;
-(void)addComment:(Comment *)theComment;
-(void)createCommentsDomain;
-(BOOL)checkIfCommentsDomainExists;
-(Comment *)getPubName:(NSString *)pubName;


// Utility Methods
-(NSArray *)convertItemsToComments:(NSArray *)items;
-(Comment *)convertSimpleDBItemToComment:(SimpleDBItem *)theItem;
-(NSString *)getPubNameFromItem:(SimpleDBItem *)theItem;
-(NSString *)getCommentFromItem:(SimpleDBItem *)theItem;
-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;
@end
