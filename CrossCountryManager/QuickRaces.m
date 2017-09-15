//
//  QuickRaces.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/9/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

#import "QuickRaces.h"
#import "RaceClass.h"
#import "RaceCell.h"
#import "AppDelegate.h"
#import "SavedRaceCell.h"
#import "RaceResults.h"
#import "RunnerOrder.h"
#import "RaceClass.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"

@interface QuickRaces ()

@end

@implementation QuickRaces {
    NSMutableArray *allRaces;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    NSMutableArray *racesByDate;
    NSMutableArray *sortedDateArray;
    NSMutableArray *sortedArray;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    [self updateData];
    [self.myTableView reloadData];
    
}

//UITableViewDelegate Methods*********************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[racesByDate objectAtIndex:section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [racesByDate count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sortedArray objectAtIndex:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    SavedRaceCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    RaceClass *currentRace = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setUpCell:currentRace quickView:true];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RaceResults *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RaceResults"];
    
    NSManagedObject *selectedRace = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    vc.comingFromLogRace = NO;
    vc.savedRace = selectedRace;
    
    [self.navigationController pushViewController:vc animated:true];
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

//Helper Methods**********************************************************************************************

-(void)updateData {
    
    NSArray *results = [GlobalFunctions getData:@"Race" context:context];
    
    allRaces = [[NSMutableArray alloc] init];
    allRaces = [results mutableCopy];
    
    NSMutableArray *uniqueDates = [[NSMutableArray alloc] init];
    for (RaceClass*race in allRaces) {
        if (![uniqueDates containsObject: race.dateString]) {
            if (![race.status  isEqual: @"pending"]) {
                [uniqueDates addObject:race.dateString];
            }
        }
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy"];
    sortedDateArray = [[NSMutableArray alloc] init];
    for (NSString *dateString in uniqueDates) {
        NSDate *date = [dateFormat dateFromString:dateString];
        [sortedDateArray addObject:date];
    }
    
    [sortedDateArray sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    racesByDate = [[NSMutableArray alloc] init];
    
    for (NSDate *date in sortedDateArray) {
        for (RaceClass *race in allRaces) {
            if ([race.dateString isEqual: [dateFormat stringFromDate:date]]) {
                [tempArray addObject: race];
            }
        }
        [racesByDate addObject: [tempArray mutableCopy]];
        [tempArray removeAllObjects];
    }
    
    sortedArray = [[NSMutableArray alloc] init];
    for (NSDate *date in sortedDateArray) {
        [sortedArray addObject:[dateFormat stringFromDate:date]];
    }
    
}

@end

