//
//  Home.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Runners.h"
#import "Races.h"

@interface Home : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)helpButtonPressed:(id)sender;

@end
