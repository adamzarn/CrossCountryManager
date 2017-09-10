//
//  RaceCell.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RaceCell.h"
#import "LogRace.h"
#import "RunnerClass.h"
#import "ResultClass.h"
#import "AppDelegate.h"

@interface RaceCell ()

@end

@implementation RaceCell {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.updateTime = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.finishButtonColor = appDelegate.darkBlue;
    self.finishButtonTextColor = [UIColor whiteColor];
    self.finishButtonTitle = @"Finish";
    self.lapButtonColor = appDelegate.darkBlue;
    self.lapButtonTextColor = [UIColor whiteColor];
    self.lapButtonTitle = @"Lap";
    
    self.lapButton.enabled = NO;
    self.lapButton.layer.cornerRadius = 25;
    self.finishButton.enabled = NO;
    self.finishButton.layer.cornerRadius = 25;
    self.finishButton.layer.borderWidth = 2;
    self.lapButton.layer.borderWidth = 2;
    
}

-(void)setUpCell:(NSString *)name currentlyRunning:(NSString *)currentlyRunning currentTime:(NSString *)currentTime startButtonPressed:(BOOL)startButtonPressed lap1:(NSString *)lap1 lap2:(NSString *)lap2 lap3:(NSString *)lap3 {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.nameLabel.text = name;
    self.timeLabel.text = currentTime;
    self.lap1Label.text = [NSString stringWithFormat:@"Lap 1: %@",lap1];
    self.lap2Label.text = [NSString stringWithFormat:@"Lap 2: %@",lap2];
    self.lap3Label.text = [NSString stringWithFormat:@"Lap 3: %@",lap3];
    
    
    //Before
    if ([currentlyRunning isEqual: @"No"] && !startButtonPressed) {
    
        self.finishButtonColor = appDelegate.lightBlue;
        self.finishButton.layer.borderColor = appDelegate.darkBlue.CGColor;
        self.lapButtonColor = appDelegate.lightBlue;
        self.lapButton.layer.borderColor = appDelegate.darkBlue.CGColor;
        self.finishButtonTextColor = [UIColor whiteColor];
        self.finishButtonTitle = @"Finish";
        self.updateTime = YES;
        self.finishButton.enabled = NO;
        self.lapButton.enabled = NO;
        self.lapButton.hidden = NO;
        self.lapButtonTitle = @"Lap";
    
    //During
    } else if ([currentlyRunning isEqual: @"Yes"] && startButtonPressed) {
        
        self.finishButtonColor = appDelegate.lightBlue;
        self.finishButton.layer.borderColor = appDelegate.darkBlue.CGColor;
        self.lapButtonColor = appDelegate.lightBlue;
        self.lapButton.layer.borderColor = appDelegate.darkBlue.CGColor;
        self.finishButtonTextColor = [UIColor whiteColor];
        self.finishButtonTitle = @"Finish";
        self.updateTime = YES;
        self.finishButton.enabled = YES;
        self.lapButton.enabled = YES;
        self.lapButton.hidden = NO;
        self.lapButtonTitle = @"Lap";
    
    //After
    } else if ([currentlyRunning isEqual: @"No"] && startButtonPressed)  {
    
        self.finishButtonColor = [UIColor whiteColor];
        self.finishButton.layer.borderColor = [UIColor whiteColor].CGColor;
        self.lapButtonColor = appDelegate.lightBlue;
        self.lapButton.layer.borderColor = appDelegate.darkBlue.CGColor;
        self.finishButtonTextColor = [UIColor blackColor];
        self.finishButtonTitle = @"Finished";
        self.updateTime = NO;
        self.finishButton.enabled = NO;
        self.lapButton.hidden = NO;
        self.lapButtonTitle = @"Undo";
        self.lapButton.enabled = YES;
        
    }
    
    [self.finishButton setBackgroundColor:self.finishButtonColor];
    [self.finishButton setTitle:self.finishButtonTitle forState:UIControlStateNormal];
    [self.finishButton setTitleColor:self.finishButtonTextColor forState:UIControlStateNormal];
    
    [self.lapButton setBackgroundColor:self.lapButtonColor];
    [self.lapButton setTitle:self.lapButtonTitle forState:UIControlStateNormal];
    [self.lapButton setTitleColor:self.lapButtonTextColor forState:UIControlStateNormal];

    LogRace *vc = self.delegate;
    if ([vc.finished isEqual: @"Yes"]) {
        self.lapButton.hidden = YES;
    }
    
}

- (IBAction)lapButtonPressed:(id)sender {

    LogRace *vc = self.delegate;
    NSInteger row = self.tag;
    
    RunnerClass *currentRunner = [vc.allRunners objectAtIndex:row];
    
    if ([self.lapButtonTitle isEqual: @"Undo"]) {
        currentRunner.currentlyRunning = @"Yes";

        for (ResultClass *result in vc.allResults) {
            if ([result.name isEqual: currentRunner.name]) {
                [vc.allResults removeObject:result];
            }
        }
        
    } else {
    
        if ([currentRunner.lap1 isEqual: @""]) {
            currentRunner.lap1 = [self getLapTime:[NSArray arrayWithObjects:@"00.00",nil] totalElapsedTime:self.timeLabel.text];
        } else if ([currentRunner.lap2 isEqual: @""]) {
            currentRunner.lap2 = [self getLapTime:[NSArray arrayWithObjects: currentRunner.lap1,nil] totalElapsedTime:self.timeLabel.text];
        } else {
            currentRunner.lap3 = [self getLapTime:[NSArray arrayWithObjects: currentRunner.lap1,currentRunner.lap2,nil] totalElapsedTime:self.timeLabel.text];
        }
        
    }
    
    [vc.allRunners replaceObjectAtIndex:row withObject:currentRunner];
    
    [vc.myTableView reloadData];
}

- (IBAction)finishButtonPressed:(id)sender {
    
    LogRace *vc = self.delegate;
    NSInteger row = self.tag;
    
    RunnerClass *currentRunner = [vc.allRunners objectAtIndex:row];
    currentRunner.currentlyRunning = @"No";
    currentRunner.currentTime = self.timeLabel.text;
    [vc.allRunners replaceObjectAtIndex:row withObject:currentRunner];

    int i = 0;
    for (RunnerClass *runner in vc.allRunners) {
        if ([runner.currentlyRunning isEqual: @"No"]) {
            i++;
        }
    }
    
    NSString *laps = [[NSString alloc] init];
    if ([currentRunner.lap1 isEqual:@""]) {
        laps = @"";
    } else if ([currentRunner.lap2 isEqual:@""]) {
        currentRunner.lap2 = [self getLapTime:[NSArray arrayWithObjects: currentRunner.lap1,nil] totalElapsedTime:self.timeLabel.text];
        laps = [NSString stringWithFormat:@"Lap 1: %@, Lap 2: %@",currentRunner.lap1,currentRunner.lap2];
    } else if ([currentRunner.lap3 isEqual:@""]) {
        currentRunner.lap3 = [self getLapTime:[NSArray arrayWithObjects: currentRunner.lap1,currentRunner.lap2,nil] totalElapsedTime:self.timeLabel.text];
        laps = [NSString stringWithFormat:@"Lap 1: %@, Lap 2: %@, Lap 3: %@",currentRunner.lap1,currentRunner.lap2,currentRunner.lap3];
    } else {
        laps = [NSString stringWithFormat:@"Lap 1: %@, Lap 2: %@, Lap 3: %@",currentRunner.lap1,currentRunner.lap2,currentRunner.lap3];
    }
    
    ResultClass *newResult = [[ResultClass alloc] init:currentRunner.name time:self.timeLabel.text pace:@"" email:currentRunner.email email2:currentRunner.email2 laps:laps];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    newResult.meet = appDelegate.meet;
    newResult.distance = appDelegate.distance;
    newResult.dateString = appDelegate.dateString;
    
    int j = 0;
    BOOL replaced = NO;
    for (ResultClass *result in vc.allResults) {
        if ([result.name isEqual: newResult.name]) {
            [vc.allResults replaceObjectAtIndex:j withObject:newResult];
            replaced = YES;
        }
        j++;
    }
    
    if (!replaced) {
        [vc.allResults addObject:newResult];
    }
    
    if (i == [vc.allRunners count]) {
        vc.finished = @"Yes";
        vc.timerLabel.text = self.timeLabel.text;
    }
    
    [vc.myTableView reloadData];
    
}

-(double)stringToSeconds:(NSString *)string {
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSRange secondsRange = NSMakeRange(3, 2);
    NSRange minutesRange = NSMakeRange(0, 2);

    NSString *seconds = [string substringWithRange:secondsRange];
    NSString *minutes = [string substringWithRange:minutesRange];

    NSNumber *s = [f numberFromString:seconds];
    NSNumber *m = [f numberFromString:minutes];
    
    return [s floatValue] + [m floatValue]*60.0;
    
}

-(NSString *)getLapTime:(NSArray *)previousLaps totalElapsedTime:(NSString *)totalElapsedTime {
    
    double previousLapsSeconds = 0.0;
    for (NSString *lap in previousLaps) {
        previousLapsSeconds = previousLapsSeconds + [self stringToSeconds:lap];
    }
    double totalSeconds = [self stringToSeconds:totalElapsedTime];
    double currentLapSeconds = totalSeconds - previousLapsSeconds;
    
    int min = floor(currentLapSeconds/60);
    int sec = floor(currentLapSeconds);
    
    if (sec >= 60) {
        sec = sec % 60;
    }
    
    NSString *currentLap = [[NSString alloc] init];
    
    currentLap = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    return currentLap;
    
}

@end
