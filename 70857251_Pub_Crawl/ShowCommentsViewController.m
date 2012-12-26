//
//  ShowCommentsViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import "ShowCommentsViewController.h"

@interface ShowCommentsViewController ()

@end

@implementation ShowCommentsViewController
@synthesize reference = _reference;
@synthesize comments = _comments;
@synthesize commentList = _commentList;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if(self)
    {
        self.title = @"Comments";
        
        // Initialise the comment and commentList objects
        _commentList = [[CommentList alloc] init];
        _comments = [[NSMutableArray alloc] initWithCapacity:0];
        _doneLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        // Initialize the commentList object and set the pub name
        self.commentList = [[CommentList alloc] init];
        self.commentList.pub  = _reference;
        
        // Retrieve all comments for the pub
        [self.comments addObjectsFromArray:[self.commentList getComments]];
        
        // Retrieve the number of comments for the pub
        int commentCount = [self.commentList commentCount];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            // Display the comment count
            self.title = [NSString stringWithFormat:@"Comments (%d)", commentCount];
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.comments count] - 1
        && _doneLoading == NO) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            // Retrieve the page of comments
            NSArray *newComments = [self.commentList getNextPageOfComments];
            if(newComments == nil || [newComments count] == 0)
            {
                _doneLoading = YES;
            }
            else
            {
                [self.comments addObjectsFromArray:newComments];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self.tableView reloadData];
            });
        });
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellStateShowingEditControlMask;
    }
    
    // Configure the cell...
    Comment *comment = [self.comments objectAtIndex:indexPath.row];
    // Main title is the pub name
    cell.textLabel.text = comment.pub;
    // Secondary title is the comment
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", comment.comment];
    
    return cell;
}

// Reloads the datasource
- (void)reloadTableViewDataSource
{
	[super performSelector:@selector(dataSourceDidFinishLoadingNewData) withObject:nil afterDelay:3.0];
}

// Called after the datasource has finished loading
- (void)dataSourceDidFinishLoadingNewData{
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[self.tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
