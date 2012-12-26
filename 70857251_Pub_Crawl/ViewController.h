//
//  ViewController.h
//  70857251_Pub_Crawl
//
//  Created by Dermot Duncan on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) NSMutableString *address;
@property (strong, nonatomic) IBOutlet UITextField *streetField;
@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UITextField *stateField;
@property (strong, nonatomic) IBOutlet UITextField *countryField;
@property (strong, nonatomic) IBOutlet UITextField *zipCodeField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *addressTypeField;

-(IBAction) segmentedControlIndexChanged;

@end
