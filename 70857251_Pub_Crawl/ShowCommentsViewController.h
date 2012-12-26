//
//  ShowCommentsViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import <UIKit/UIKit.h>
#import "CommentList.h"

@interface ShowCommentsViewController : UITableViewController
{
    BOOL _doneLoading;
}

@property (nonatomic, strong) NSString *reference;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) CommentList *commentList;

@end
