//
//  LogRace.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "LogRace.h"
#import "QuickRaces.h"
#import "Runners.h"
#import "RaceCell.h"
#import "RunnerClass.h"
#import "AppDelegate.h"
#import "RaceResults.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"

@interface LogRace ()

@end

@implementation LogRace {
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    BOOL startButtonPressed;
}
@synthesize timerLabel, startButton;

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    self.allResults = [[NSMutableArray alloc] init];
    self.myTableView.delegate = self;
    
    [self setUp];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.myTableView.allowsSelection = NO;
    self.pastRaceResultsButton.style = UIBarButtonItemStyleDone;
    self.pastRaceResultsButton.tintColor = appDelegate.darkBlue;
    
    self.toolbar.translucent = NO;
    
}

//UITableViewDelegate Methods*********************************************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allRunners count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RaceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    RunnerClass *currentRunner = [self.allRunners objectAtIndex:indexPath.row];
    
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    [cell setUpCell:currentRunner.name currentlyRunning:currentRunner.currentlyRunning finishTime:currentRunner.finishTime startButtonPressed:startButtonPressed lap1:currentRunner.lap1 lap2:currentRunner.lap2 lap3:currentRunner.lap3];
    
    if (running == YES && cell.updateTime == YES) {
        cell.finishButton.enabled = YES;
    }
    
    if (running == YES && cell.updateTime == NO) {
        cell.finishButton.enabled = NO;
    }
    
    if (![currentRunner.lap3 isEqual: @""] && cell.updateTime == YES) {
        cell.lapButton.enabled = NO;
        cell.lapButton.hidden = YES;
    }
    
    if ([self.finished isEqual: @"Yes"] && startButtonPressed == YES) {
        
        running = NO;
        [myTimer invalidate];
        myTimer = nil;
        [startButton setTitle:@"Finished" forState:UIControlStateNormal];
        [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [startButton setBackgroundColor:[UIColor whiteColor]];
        startButton.layer.borderColor = [UIColor whiteColor].CGColor;
        [NSUserDefaults.standardUserDefaults setDouble:0.0 forKey:@"secondsAccrued"];
        
        [self presentRaceFinishedAlert];
        
    }
    
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ - %@ miles",[self.savedRace valueForKey:@"group"],[self.savedRace valueForKey:@"distance"]];
}

//IBActions***************************************************************************************************

- (void)saveRace {
    
    RaceResults *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RaceResults"];
    
    for (ResultClass *result in self.allResults) {
        NSString *pace = [GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:result,nil]];
        result.pace = pace;
    }
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M/d/yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    [self.savedRace setValue:dateString forKey:@"dateString"];
    [self.savedRace setValue:@"finished" forKey:@"status"];
    
    for (ResultClass *result in self.allResults) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", result.name];
        NSArray *filteredArray = [self.allRunners filteredArrayUsingPredicate:predicate];
        
        NSManagedObject *currentRunner = [filteredArray objectAtIndex:0];
        
        NSManagedObject *savedResult = [NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:context];
        [savedResult setValue:result.name forKey:@"name"];
        [savedResult setValue:result.time forKey:@"time"];
        [savedResult setValue:result.pace forKey:@"pace"];
        [savedResult setValue:result.lap1 forKey:@"lap1"];
        [savedResult setValue:result.lap2 forKey:@"lap2"];
        [savedResult setValue:result.lap3 forKey:@"lap3"];
        [savedResult setValue:result.meet forKey:@"meet"];
        [savedResult setValue:result.distance forKey:@"distance"];
        [savedResult setValue:dateString forKey:@"dateString"];
        [savedResult setValue:self.savedRace forKey:@"resultToRace"];
        [savedResult setValue:currentRunner forKey:@"resultToRunner"];
        
    }
    
    [appDelegate saveContext];
    
    vc.savedRace = self.savedRace;
    vc.results = self.allResults;
    vc.comingFromLogRace = YES;
    
    [self.navigationController pushViewController:vc animated:false];
    
}

- (void) presentRaceFinishedAlert {
    UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Race Finished" message:@"Would you like to save or discard these results?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *discard = [UIAlertAction actionWithTitle:@"Discard" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self saveRace];
    }];
    
    [alert addAction:discard];
    [alert addAction:save];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)resetButtonPressed:(id)sender {
    UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Reset" message:@"Are you sure you want to reset every runner's clock?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self setUp];
    }];
    
    [alert addAction:cancel];
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (IBAction)startButtonPressed:(id)sender {
    
    self.resetButton.enabled = YES;
    
    if (startButtonPressed == NO) {
        startButtonPressed = YES;
        for (RunnerClass *runner in self.allRunners) {
            runner.currentlyRunning = @"Yes";
        }
    }
    
    if (running == NO) {
        running = YES;
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
        if (myTimer == nil) {
            myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
            NSDate *startTime = [NSDate date];
            [NSUserDefaults.standardUserDefaults setValue:startTime forKey:@"startTime"];
        }
        [self.myTableView reloadData];
        
    } else {
        running = NO;
        [myTimer invalidate];
        myTimer = nil;
        
        NSDate *startDate = [NSUserDefaults.standardUserDefaults valueForKey:@"startTime"];
        NSDate *currentDate = [NSDate date];
        
        NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:startDate];
        NSTimeInterval secondsAccrued = [NSUserDefaults.standardUserDefaults doubleForKey:@"secondsAccrued"];
        NSTimeInterval newSecondsAccrued = secondsAccrued + secondsBetween;
        
        [NSUserDefaults.standardUserDefaults setDouble:newSecondsAccrued forKey:@"secondsAccrued"];
        
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (IBAction)pastRaceResultsButtonPressed:(id)sender {
    QuickRaces *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"QuickRaces"];
    [self.navigationController pushViewController:viewController animated:YES];
}


//Helper Methods**********************************************************************************************

-(void)setUp {
    
    [NSUserDefaults.standardUserDefaults setDouble:0.0 forKey:@"secondsAccrued"];
    
    self.finished = @"No";
    if ([self.allResults count] > 0) {
        [self.allResults removeAllObjects];
    }
    
    for (RunnerClass *runner in self.allRunners) {
        runner.currentlyRunning = @"No";
        runner.finishTime = @"";
        runner.lap1 = @"";
        runner.lap2 = @"";
        runner.lap3 = @"";
    }
    
    running = NO;
    timerLabel.text = @"00:00";
    [self.myTableView reloadData];
    
    if (startButtonPressed) {
        [myTimer invalidate];
        myTimer = nil;
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
    
    [self.startButton setBackgroundColor:appDelegate.lightBlue];
    self.startButton.layer.borderColor = appDelegate.darkBlue.CGColor;
    self.startButton.layer.borderWidth = 2;
    startButton.layer.cornerRadius = 35;
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.enabled = NO;
    startButtonPressed = NO;

}

- (IBAction)cancelButtonPressed:(id)sender {
    UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Cancel" message:@"This will discard all times already logged (though you will still be able to start this race again from \"Pending\" Races). Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    
    [alert addAction:cancel];
    [alert addAction:yes];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)updateTimer {
    
    NSDate *startDate = [NSUserDefaults.standardUserDefaults valueForKey:@"startTime"];
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval secondsBetween = [currentDate timeIntervalSinceDate:startDate];
    NSTimeInterval secondsAccrued = [NSUserDefaults.standardUserDefaults doubleForKey:@"secondsAccrued"];
    NSTimeInterval totalTimeElapsed = secondsBetween + secondsAccrued;
    
    int min = floor(totalTimeElapsed/1/60);
    int sec = floor(totalTimeElapsed/1);
    
    if (sec >= 60) {
        sec = sec % 60;
    }
    
    timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",min,sec];

}

@end
