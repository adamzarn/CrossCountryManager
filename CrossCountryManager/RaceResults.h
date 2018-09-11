//
//  RaceResults.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "RaceClass.h"
@import GoogleMobileAds;

@interface RaceResults : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate> {

}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property BOOL comingFromLogRace;
@property NSManagedObject *savedRace;
@property NSMutableArray *results;
@property (weak, nonatomic) IBOutlet UIView *editResultView;

@property (weak, nonatomic) IBOutlet UIButton *saveResultButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;

@property (weak, nonatomic) IBOutlet UITextField *lap1TextField;
@property (weak, nonatomic) IBOutlet UITextField *lap2TextField;
@property (weak, nonatomic) IBOutlet UITextField *lap3TextField;

@property (weak, nonatomic) IBOutlet UILabel *editResultLabel;

@property(nonatomic, strong) GADBannerView *bannerView;

@property NSMutableArray *pickerOptions;

- (IBAction)emailButtonPressed:(id)sender;


@end
