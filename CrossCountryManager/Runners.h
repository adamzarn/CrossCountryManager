//
//  Runners.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunnerClass.h"
#import "PersonViewDelegate.h"
@import GoogleMobileAds;

@interface Runners : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GADBannerViewDelegate, PersonViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *teamSegment;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;



@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeAdsButton;

@property(nonatomic, strong) GADBannerView *bannerView;

@property RunnerClass *currentRunner;
@property NSString *photoOrientation;
@property NSManagedObjectContext *context;


- (void)addRunner:(id)sender;
- (void)editRunner:(NSIndexPath *)indexPath;
-(void)choosePicture;
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end

