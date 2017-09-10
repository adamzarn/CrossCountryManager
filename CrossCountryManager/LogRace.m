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
    self.saveButton.style = UIBarButtonSystemItemDone;
    self.pastRaceResultsButton.style = UIBarButtonItemStyleDone;
    self.pastRaceResultsButton.tintColor = appDelegate.darkBlue;
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
    
    [cell setUpCell:currentRunner.name currentlyRunning:currentRunner.currentlyRunning currentTime:currentRunner.currentTime startButtonPressed:startButtonPressed lap1:currentRunner.lap1 lap2:currentRunner.lap2 lap3:currentRunner.lap3];
    
    if (cell.updateTime == YES) {
        cell.timeLabel.text = self.timerLabel.text;
    }
    
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
        self.saveButton.enabled = YES;
        self.saveButton.style = UIBarButtonSystemItemDone;
        [startButton setTitle:@"Finished" forState:UIControlStateNormal];
        [startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [startButton setBackgroundColor:[UIColor whiteColor]];
        startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    
    return cell;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@ - %@ miles",appDelegate.group,appDelegate.distance];
}

//IBActions***************************************************************************************************

- (IBAction)saveButtonPressed:(id)sender {
    
    RaceResults *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RaceResults"];
    
    for (ResultClass *result in self.allResults) {
        NSString *pace = [GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:result,nil]];
        result.pace = pace;
    }
    
    [self.savedRace setValue:@"finished" forKey:@"status"];
    
    for (ResultClass *result in self.allResults) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", result.name];
        NSArray *filteredArray = [self.allRunners filteredArrayUsingPredicate:predicate];
        
        NSManagedObject *currentRunner = [filteredArray objectAtIndex:0];
        
        NSManagedObject *savedResult = [NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:context];
        [savedResult setValue:result.name forKey:@"name"];
        [savedResult setValue:result.time forKey:@"time"];
        [savedResult setValue:result.pace forKey:@"pace"];
        [savedResult setValue:result.email forKey:@"email"];
        [savedResult setValue:result.email2 forKey:@"email2"];
        [savedResult setValue:result.laps forKey:@"laps"];
        [savedResult setValue:result.meet forKey:@"meet"];
        [savedResult setValue:result.distance forKey:@"distance"];
        [savedResult setValue:result.dateString forKey:@"dateString"];
        [savedResult setValue:self.savedRace forKey:@"resultToRace"];
        [savedResult setValue:currentRunner forKey:@"resultToRunner"];
        
    }
    
    [appDelegate saveContext];
    
    vc.race = (RaceClass *) self.savedRace;
    vc.results = self.allResults;
    vc.comingFromLogRace = YES;
    
    [self.navigationController pushViewController:vc animated:false];
    
}

- (IBAction)resetButtonPressed:(id)sender {
    UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Reset" message:@"Are you sure you want to reset every runner's clock?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        [self setUp];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
    
    [alert addAction:yes];
    [alert addAction:cancel];
    
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
            myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:myTimer forMode:NSRunLoopCommonModes];
        }
        
    } else {
        running = NO;
        [myTimer invalidate];
        myTimer = nil;
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (IBAction)pastRaceResultsButtonPressed:(id)sender {
    QuickRaces *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"QuickRaces"];
    [self.navigationController pushViewController:viewController animated:YES];
}


//Helper Methods**********************************************************************************************

-(void)setUp {
    
    self.finished = @"No";
    if ([self.allResults count] > 0) {
        [self.allResults removeAllObjects];
    }
    
    for (RunnerClass *runner in self.allRunners) {
        runner.currentlyRunning = @"No";
        runner.currentTime = @"00:00";
        runner.lap1 = @"";
        runner.lap2 = @"";
        runner.lap3 = @"";
    }
    
    running = NO;
    count = 0;
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
    self.saveButton.enabled = NO;
}

- (void)updateTimer {
    count++;
    int min = floor(count/1/60);
    int sec = floor(count/1);
    
    if (sec >= 60) {
        sec = sec % 60;
    }
    
    timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",min,sec];

    [self.myTableView reloadData];
}

@end
