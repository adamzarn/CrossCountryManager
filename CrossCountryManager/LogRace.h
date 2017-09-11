//
//  LogRace.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceClass.h"
#import "CoreData/CoreData.h"

@interface LogRace : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSTimer *myTimer;
    BOOL running;
    int count;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) NSString *predicate;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) NSMutableArray *allRunners;
@property (nonatomic, retain) NSMutableArray *allResults;
@property (nonatomic, retain) NSString *finished;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pastRaceResultsButton;
@property (nonatomic, retain) NSManagedObject *savedRace;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;


- (IBAction)startButtonPressed:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;

@end
