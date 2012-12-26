//
//  PhotoUploaderViewController.m
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import "PhotoUploaderViewController.h"
#import "AmazonClientManager.h"
#import <AWSiOSSDK/S3/AmazonS3Client.h>

@interface PhotoUploaderViewController ()

@end

@implementation PhotoUploaderViewController

@synthesize imageView,choosePhotoBtn, takePhotoBtn;
@synthesize reference = _reference;
@synthesize buckets = _buckets;
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
    [AmazonLogger verboseLogging];
    
    // Retrieve all buckets and initialize the buckets array
    NSArray *bucketNames = [[AmazonClientManager s3] listBuckets];
    if (_buckets == nil) {
        _buckets = [[NSMutableArray alloc] initWithCapacity:[bucketNames count]];
    }
    else {
        [_buckets removeAllObjects];
    }

    // Check if a bucket exists for this pub
    if (bucketNames != nil) {
        for (S3Bucket *bucket in bucketNames) {
            [_buckets addObject:[bucket name]];
            if ([bucket name] == [_reference lowercaseString])
                _pubsBucket = bucket;
        }
    }
    
    // Sort the bucket array
    [_buckets sortUsingSelector:@selector(compare:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    imageView = nil;
    [super viewDidUnload];
}

-(IBAction) getPhoto:(id) sender {
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	if((UIBarButtonItem *) sender == choosePhotoBtn) {
		picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	} else {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
    
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[picker dismissModalViewControllerAnimated:YES];
	imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Check if a bucket exists for this pub
    if (_pubsBucket == Nil) {
        // If it doesn't create a new one
        S3CreateBucketRequest *request = [[S3CreateBucketRequest alloc] initWithName:[_reference lowercaseString]];
        S3CreateBucketResponse *response = [[AmazonClientManager s3] createBucket:request];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
        }
        
        // Retrieve all buckets
        NSArray *bucketNames = [[AmazonClientManager s3] listBuckets];
        
        // Initialize the newly created bucket object for this pub
        for (S3Bucket *bucket in bucketNames) {
            if ([bucket name] == [_reference lowercaseString])
                _pubsBucket = bucket;
        }
    }
    
    // Translate the image into a data object to upload
    NSData *imageData = UIImagePNGRepresentation(imageView.image);
    
    int r = arc4random() % 1179;
    NSString *picName = [NSString stringWithFormat:@"%@%d", [_reference lowercaseString], r];
    // Add the image data to the bucket
    S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey:picName inBucket:[_reference lowercaseString]];
    request.data = imageData;

    
    S3PutObjectResponse *response = [[AmazonClientManager s3] putObject:request];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
    }

}

@end
