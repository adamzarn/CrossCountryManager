//
//  RacesOfRunner.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SavedRaceCell.h"
#import "ResultClass.h"

@interface RacesOfRunner : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *predArray;

- (IBAction)emailButtonPressed:(id)sender;

@end
