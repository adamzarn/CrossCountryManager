//
//  RunnerOrder.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceClass.h"
#import <CoreData/CoreData.h>

@interface RunnerOrder : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveForLaterButton;

@property (nonatomic, retain) NSString *predicate;
@property (nonatomic, retain) NSMutableArray *presentRunners;
@property (nonatomic, retain) NSMutableArray *absentRunners;
@property (nonatomic, retain) NSMutableArray *runnerOrder;
@property (nonatomic, retain) NSManagedObject *savedRace;

@end
