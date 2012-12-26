//
//  PubPhotosViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 12/20/12.
//
//

#import <UIKit/UIKit.h>
#import "AmazonClientManager.h"
#import "PubPhotoViewCell.h"

@interface PubPhotosViewController : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property(nonatomic,retain) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *pubImages;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) S3Bucket *pubsBucket;

@end
