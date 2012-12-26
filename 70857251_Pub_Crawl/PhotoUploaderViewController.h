//
//  PhotoUploaderViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"

@interface PhotoUploaderViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	UIImageView * imageView;
	UIBarButtonItem * choosePhotoBtn;
	UIBarButtonItem * takePhotoBtn;
}

@property (nonatomic, retain) IBOutlet UIImageView * imageView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * choosePhotoBtn;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * takePhotoBtn;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSMutableArray *buckets;
@property (nonatomic, strong) S3Bucket *pubsBucket;

-(IBAction) getPhoto:(id) sender;

@end