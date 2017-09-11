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

@interface RaceResults : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {

}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property BOOL comingFromLogRace;
@property NSManagedObject *savedRace;
@property NSMutableArray *results;

- (IBAction)emailButtonPressed:(id)sender;


@end
