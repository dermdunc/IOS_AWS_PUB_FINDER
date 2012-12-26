//
//  PubPhotosViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import "PubPhotosViewController.h"
#import "AmazonClientManager.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface PubPhotosViewController ()

@end

@implementation PubPhotosViewController

@synthesize pubImages = _pubImages;
@synthesize reference = _reference;
@synthesize pubsBucket = _pubsBucket;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        [AmazonErrorHandler shouldNotThrowExceptions];
        // Retrieve all buckets
        NSArray *bucketNames = [[AmazonClientManager s3] listBuckets];
        
        // Check if a bucket exists for this pub
        if (bucketNames != nil) {
            for (S3Bucket *bucket in bucketNames) {
                if ([bucket name] == [_reference lowercaseString])
                    _pubsBucket = bucket;
            }
        }
        
        // Retrieve all the images from the bucket
        S3ListObjectsRequest  *listObjectRequest = [[S3ListObjectsRequest alloc] initWithName:[_reference lowercaseString]];
        S3ListObjectsResponse *listObjectResponse = [[AmazonClientManager s3] listObjects:listObjectRequest];
        if(listObjectResponse.error != nil)
        {
            NSLog(@"Error: %@", listObjectResponse.error);
            [_pubImages addObject:@"Unable to load objects!"];
        }
        else
        {
            // Retrieve all the objects in the bucket
            S3ListObjectsResult *listObjectsResults = listObjectResponse.listObjectsResult;
            
            if (_pubImages == nil) {
                _pubImages = [[NSMutableArray alloc] initWithCapacity:[listObjectsResults.objectSummaries count]];
            }
            else {
                [_pubImages removeAllObjects];
            }
            
            // By defrault, listObjects will only return 1000 keys
            // This code will fetch all objects in bucket.
            // NOTE: This could cause the application to run out of memory
            NSString *lastKey = @"";
            for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                [_pubImages addObject:[objectSummary key]];
                lastKey = [objectSummary key];
            }
            
            while (listObjectsResults.isTruncated) {
                listObjectRequest = [[S3ListObjectsRequest alloc] initWithName:[_reference lowercaseString]];
                listObjectRequest.marker = lastKey;
                
                listObjectResponse = [[AmazonClientManager s3] listObjects:listObjectRequest];
                if(listObjectResponse.error != nil)
                {
                    NSLog(@"Error: %@", listObjectResponse.error);
                    [_pubImages addObject:@"Unable to load objects!"];
                    
                    break;
                }
                
                listObjectsResults = listObjectResponse.listObjectsResult;
                
                for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                    [_pubImages addObject:[objectSummary key]];
                    lastKey = [objectSummary key];
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    //[self setImageView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return _pubImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PubPhotoViewCell *pubPhotoCell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"PubPhotoCell"
                                    forIndexPath:indexPath];
    
    UIImage *image;
    int row = [indexPath row];
    
    image = [UIImage imageNamed:_pubImages[row]];
    
    pubPhotoCell.imageView.image = image;
    
    return pubPhotoCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pubImages count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    cell.textLabel.text = [_pubImages objectAtIndex:indexPath.row];
    
    return cell;
}
@end
