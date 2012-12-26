//
//  PubDetailViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GooglePlacesConnection.h"

@interface PubDetailViewController : UIViewController <GooglePlacesConnectionDelegate>
{
    GooglePlacesConnection  *googlePlacesConnection;
}
- (IBAction)commentBtnPushed:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *placeName;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (nonatomic, retain) IBOutlet UILabel *placeFormattedAddress;
@property (nonatomic, strong) IBOutlet UILabel *placePhoneNumber;
@property (nonatomic, retain) IBOutlet UILabel *placeRating;
@property (nonatomic, retain) IBOutlet UILabel *placeWebsite;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) GooglePlacesObject *place;

@end
