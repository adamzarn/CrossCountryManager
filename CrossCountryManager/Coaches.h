//
//  Coaches.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewDelegate.h"
@import GoogleMobileAds;

@interface Coaches: UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, GADBannerViewDelegate, PersonViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property(nonatomic, strong) GADBannerView *bannerView;

@property NSManagedObjectContext *context;

- (void)addCoach:(id)sender;
- (void)editCoach:(NSIndexPath *)indexPath;

@end
