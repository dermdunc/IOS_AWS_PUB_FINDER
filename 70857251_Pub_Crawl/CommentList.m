//
//  CommentList.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import "CommentList.h"
#import "AmazonClientManager.h"

#define COMMENT_DOMAIN    @"Comments"

#define PUB_ATTRIBUTE     @"pub"
#define COMMENT_ATTRIBUTE      @"comment"

#define COUNT_QUERY          @"select count(*) from Comments"

@implementation CommentList

@synthesize nextToken;
@synthesize pub = _pub;


-(id)init
{
    self = [super init];
    if (self)
    {
        // Initial the SimpleDB Client.
        self.nextToken = nil;
    }
    
    return self;
}

/*
 * Method returns the number of items in the Comments Domain.
 */
-(int)commentCount
{
    [AmazonLogger verboseLogging];
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc] initWithSelectExpression:COUNT_QUERY];
    selectRequest.consistentRead = YES;
    
    SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb] select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return 0;
    }
    
    SimpleDBItem *countItem = [selectResponse.items objectAtIndex:0];
    
    return [self getIntValueForAttribute:@"Count" fromList:countItem.attributes];
}

/*
 * Gets the item from the Comments domain with the item name equal to 'thePub'.
 */
-(Comment *)getComment:(NSString *)thePub
{
    [AmazonLogger verboseLogging];
    SimpleDBGetAttributesRequest *gar = [[SimpleDBGetAttributesRequest alloc] initWithDomainName:COMMENT_DOMAIN andItemName:thePub];
    SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:gar];

    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
        return nil;
    }
    
    NSString *pubName = [self getStringValueForAttribute:PUB_ATTRIBUTE fromList:response.attributes];
    NSString *comment = [self getStringValueForAttribute:COMMENT_ATTRIBUTE fromList:response.attributes];
    
    return [[Comment alloc] initWithPub:pubName andComment:comment];
}

/*
 * Using the pre-defined query, extracts items from the domain in a determined order using the 'select' operation.
 */
-(NSArray *)getComments
{
    [AmazonLogger verboseLogging];
    NSString *query = [NSString stringWithFormat:@"select * from Comments where itemname() = '%@'", _pub.lowercaseString];
    NSLog(@"%@", query);
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc] initWithSelectExpression:query];
    selectRequest.consistentRead = YES;
    if (self.nextToken != nil) {
        selectRequest.nextToken = self.nextToken;
    }
    
    SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb] select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return [NSArray array];
    }
    
    self.nextToken = selectResponse.nextToken;
    
    return [self convertItemsToComments:selectResponse.items];
}

/*
 * If a 'nextToken' was returned on the previous query execution, use the next token to get the next batch of items.
 */
-(NSArray *)getNextPageOfComments
{
    if (self.nextToken == nil) {
        return [NSArray array];
    }
    else {
        return [self getComments];
    }
}

/*
 * Creates a new item and adds it to the Comments domain.
 */
-(void)addComment:(Comment *)theComment
{
    
    [AmazonLogger verboseLogging];
    SimpleDBReplaceableAttribute *pubAttribute = [[SimpleDBReplaceableAttribute alloc] initWithName:PUB_ATTRIBUTE andValue:theComment.pub.lowercaseString andReplace:YES];
    SimpleDBReplaceableAttribute *commentAttribute  = [[SimpleDBReplaceableAttribute alloc] initWithName:COMMENT_ATTRIBUTE andValue:theComment.comment andReplace:YES];
    
    NSMutableArray *attributes = [[NSMutableArray alloc] initWithCapacity:1];
    [attributes addObject:pubAttribute];
    [attributes addObject:commentAttribute];
    
    SimpleDBPutAttributesRequest *putAttributesRequest = [[SimpleDBPutAttributesRequest alloc] initWithDomainName:COMMENT_DOMAIN andItemName:theComment.pub.lowercaseString andAttributes:attributes];
    
    SimpleDBPutAttributesResponse *putAttributesResponse = [[AmazonClientManager sdb] putAttributes:putAttributesRequest];
    if(putAttributesResponse.error != nil)
    {
        NSLog(@"Error: %@", putAttributesResponse.error);
    }
}

/*
 * Removes the item from the Comments domain.
 * The item removes is the item whose 'pub' matches the theComment submitted.
 */
-(void)removeComment:(Comment *)theComment
{
    [AmazonLogger verboseLogging];
    @try {
        SimpleDBDeleteAttributesRequest *deleteItem = [[SimpleDBDeleteAttributesRequest alloc] initWithDomainName:COMMENT_DOMAIN andItemName:theComment.pub];
        [sdbClient deleteAttributes:deleteItem];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception : [%@]", exception);
    }
}

/*
 * Creates the Comment domain.
 */
-(void)createCommentsDomain
{
    [AmazonLogger verboseLogging];
    SimpleDBCreateDomainRequest *createDomain = [[SimpleDBCreateDomainRequest alloc] initWithDomainName:COMMENT_DOMAIN];
    SimpleDBCreateDomainResponse *createDomainResponse = [[AmazonClientManager sdb] createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

-(BOOL)checkIfCommentsDomainExists
{
    [AmazonErrorHandler shouldNotThrowExceptions];
    [AmazonLogger verboseLogging];
    
    NSString *selectExpression = [NSString stringWithFormat:@"select * from `%@`", COMMENT_DOMAIN];
    
    SimpleDBSelectRequest *selectRequest = [[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression];
    SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb] select:selectRequest];
    if(selectResponse.error != nil)
    {
        NSLog(@"Error: %@", selectResponse.error);
        return false;
    }
    
    return true;    
        
    
}

/*
 * Deletes the Comment domain.
 */
-(void)clearComments
{
    [AmazonLogger verboseLogging];
    SimpleDBDeleteDomainRequest *deleteDomain = [[SimpleDBDeleteDomainRequest alloc] initWithDomainName:COMMENT_DOMAIN];
    SimpleDBDeleteDomainResponse *deleteDomainResponse = [[AmazonClientManager sdb] deleteDomain:deleteDomain];
    if(deleteDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteDomainResponse.error);
    }
    
    SimpleDBCreateDomainRequest *createDomain = [[SimpleDBCreateDomainRequest alloc] initWithDomainName:COMMENT_DOMAIN];
    SimpleDBCreateDomainResponse *createDomainResponse = [[AmazonClientManager sdb] createDomain:createDomain];
    if(createDomainResponse.error != nil)
    {
        NSLog(@"Error: %@", createDomainResponse.error);
    }
}

/*
 * Converts an array of Items into an array of HighScore objects.
 */
-(NSArray *)convertItemsToComments:(NSArray *)theItems
{
    NSMutableArray *comments = [[NSMutableArray alloc] initWithCapacity:[theItems count]];
    for (SimpleDBItem *item in theItems) {
        [comments addObject:[self convertSimpleDBItemToComment:item]];
    }
    
    return comments;
}

/*
 * Converts a single SimpleDB Item into a HighScore object.
 */
-(Comment *)convertSimpleDBItemToComment:(SimpleDBItem *)theItem
{
    return [[Comment alloc] initWithPub:[self getPubNameFromItem:theItem] andComment:[self getCommentFromItem:theItem]];
}

/*
 * Extracts the 'player' attribute from the SimpleDB Item.
 */
-(NSString *)getPubNameFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:PUB_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the 'comment' attribute from the SimpleDB Item.
 */
-(NSString *)getCommentFromItem:(SimpleDBItem *)theItem
{
    return [self getStringValueForAttribute:COMMENT_ATTRIBUTE fromList:theItem.attributes];
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as a NSString.
 */
-(NSString *)getStringValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return attribute.value;
        }
    }
    
    return @"";
}

/*
 * Extracts the value for the given attribute from the list of attributes.
 * Extracted value is returned as an int.
 */
-(int)getIntValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (SimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return [attribute.value intValue];
        }
    }
    
    return 0;
}

@end

