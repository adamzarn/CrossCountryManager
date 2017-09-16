//
//  RunnerOrder.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RunnerOrder.h"
#import "LogRace.h"
#import "AppDelegate.h"
#import "RaceClass.h"
#import "RunnerClass.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"
#import "Races.h"

@interface RunnerOrder ()

@end

@implementation RunnerOrder {
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    NSArray *sortedResults;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    self.presentRunners = [[NSMutableArray alloc] init];
    self.absentRunners = [[NSMutableArray alloc] init];
    
    if (self.runnerOrder == nil) {
        NSArray *runnerResults = [GlobalFunctions getData:@"Runner" pred:self.predicate context:context];
        results = [runnerResults mutableCopy];
        
        self.presentRunners = [results mutableCopy];
        
    } else {
        for (NSString *name in [self.runnerOrder objectAtIndex:0]) {
            RunnerClass *newRunner = [GlobalFunctions getCurrentRunner:@"Runner" pred:@"name == %@" name:name context:context];
            [self.presentRunners addObject:newRunner];
        }
        for (NSString *name in [self.runnerOrder objectAtIndex:1]) {
            RunnerClass *newRunner = [GlobalFunctions getCurrentRunner:@"Runner" pred:@"name == %@" name:name context:context];
            [self.absentRunners addObject:newRunner];
        }
    }
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (self.runnerOrder == nil) {
    
        for (RunnerClass *runner in self.presentRunners) {
            NSManagedObject *managedRunner = [self.presentRunners objectAtIndex:[self.presentRunners indexOfObject:runner]];
            NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRunner = %@" predArray:[NSArray arrayWithObjects: managedRunner, nil] context:context];
            runner.averageMileTime = [GlobalFunctions getAverageMileTime:results];
        }
        
        sortedResults = [self.presentRunners sortedArrayUsingComparator: ^(RunnerClass *runner1, RunnerClass *runner2) {
            double key1 = [GlobalFunctions getSecondsPerMile:runner1.averageMileTime];
            double key2 = [GlobalFunctions getSecondsPerMile:runner2.averageMileTime];
            if (key1 > key2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if (key1 < key2) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        self.presentRunners = [sortedResults mutableCopy];
        
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.saveForLaterButton.style = UIBarButtonItemStyleDone;
    self.saveForLaterButton.tintColor = appDelegate.darkBlue;
    
    self.toolbar.translucent = NO;
    
    if (self.savedRace == nil) {
        UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:@"Runner Order" bottomLine:self.race.group];
        self.navigationItem.titleView = twoLineTitleView;
    } else {
        UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:@"Runner Order" bottomLine:[self.savedRace valueForKey:@"group"]];
        self.navigationItem.titleView = twoLineTitleView;
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self.myTableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    [self.navigationItem.rightBarButtonItem setTitle:@"Next"];
}

//UITableViewDelegate Methods*********************************************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.presentRunners count];
    } else {
        return [self.absentRunners count];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[NSArray arrayWithObjects:@"Present", @"Absent", nil] objectAtIndex:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    RunnerClass *runner = [[RunnerClass alloc] init];
    if (indexPath.section == 0) {
        runner = [self.presentRunners objectAtIndex:indexPath.row];
    } else {
        runner = [self.absentRunners objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = runner.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ per mile",runner.averageMileTime];
    
    return cell;
    
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    RunnerClass *movingRunner = [[RunnerClass alloc] init];
    if (sourceIndexPath.section == 0) {
        movingRunner = [self.presentRunners objectAtIndex:sourceIndexPath.row];
    } else {
        movingRunner = [self.absentRunners objectAtIndex:sourceIndexPath.row];
    }
    if (sourceIndexPath.section == 0 && destinationIndexPath.section == 1) {
        [self.presentRunners removeObjectAtIndex:sourceIndexPath.row];
        [self.absentRunners insertObject:movingRunner atIndex:destinationIndexPath.row];
    }
    if (sourceIndexPath.section == 1 && destinationIndexPath.section == 0) {
        [self.absentRunners removeObjectAtIndex:sourceIndexPath.row];
        [self.presentRunners insertObject:movingRunner atIndex:destinationIndexPath.row];
    }
    if (sourceIndexPath.section == 0 && destinationIndexPath.section == 0) {
        [self.presentRunners removeObjectAtIndex:sourceIndexPath.row];
        [self.presentRunners insertObject:movingRunner atIndex:destinationIndexPath.row];
    }
    if (sourceIndexPath.section == 1 && destinationIndexPath.section == 1) {
        [self.absentRunners removeObjectAtIndex:sourceIndexPath.row];
        [self.absentRunners insertObject:movingRunner atIndex:destinationIndexPath.row];
    }
}

//Helper Methods**********************************************************************************************

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    NSMutableArray *runnerOrder = [[NSMutableArray alloc] init];
    NSMutableArray *presentArray = [[NSMutableArray alloc] init];
    NSMutableArray *absentArray = [[NSMutableArray alloc] init];
    for (RunnerClass *runner in self.presentRunners) {
        [presentArray addObject:runner.name];
    }
    for (RunnerClass *runner in self.absentRunners) {
        [absentArray addObject:runner.name];
    }
    [runnerOrder addObject:presentArray];
    [runnerOrder addObject:absentArray];
    
    if (self.savedRace == nil) {

        NSManagedObject *savedRace = [NSEntityDescription insertNewObjectForEntityForName:@"Race" inManagedObjectContext:context];
        [savedRace setValue:self.race.dateString forKey:@"dateString"];
        [savedRace setValue:self.race.meet forKey:@"meet"];
        [savedRace setValue:self.race.distance forKey:@"distance"];
        [savedRace setValue:self.race.gender forKey:@"gender"];
        [savedRace setValue:self.race.team forKey:@"team"];
        [savedRace setValue:self.race.group forKey:@"group"];
        [savedRace setValue:runnerOrder forKey:@"runnerOrder"];
        [savedRace setValue:@"pending" forKey:@"status"];
        self.savedRace = savedRace;
        
    } else {

        [self.savedRace setValue:runnerOrder forKey:@"runnerOrder"];
        
    }
    
    [appDelegate saveContext];

    [self.savedRace setValue:runnerOrder forKey:@"runnerOrder"];
    
    LogRace *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"LogRace"];
    vc.allRunners = self.presentRunners;
    vc.savedRace = self.savedRace;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)saveForLaterButtonPressed:(id)sender {
    
    NSMutableArray *runnerOrder = [[NSMutableArray alloc] init];
    NSMutableArray *presentArray = [[NSMutableArray alloc] init];
    NSMutableArray *absentArray = [[NSMutableArray alloc] init];
    for (RunnerClass *runner in self.presentRunners) {
        [presentArray addObject:runner.name];
    }
    for (RunnerClass *runner in self.absentRunners) {
        [absentArray addObject:runner.name];
    }
    [runnerOrder addObject:presentArray];
    [runnerOrder addObject:absentArray];
    
    if (self.savedRace == nil) {
        
        NSManagedObject *savedRace = [NSEntityDescription insertNewObjectForEntityForName:@"Race" inManagedObjectContext:context];
        [savedRace setValue:self.race.dateString forKey:@"dateString"];
        [savedRace setValue:self.race.meet forKey:@"meet"];
        [savedRace setValue:self.race.distance forKey:@"distance"];
        [savedRace setValue:self.race.gender forKey:@"gender"];
        [savedRace setValue:self.race.team forKey:@"team"];
        [savedRace setValue:self.race.group forKey:@"group"];
        [savedRace setValue:runnerOrder forKey:@"runnerOrder"];
        [savedRace setValue:@"pending" forKey:@"status"];
        
    } else {
        
        [self.savedRace setValue:runnerOrder forKey:@"runnerOrder"];
        
    }
    
    [appDelegate saveContext];
    
    [self.navigationController popViewControllerAnimated:true];
    
}

- (void) saveCurrentRunnerOrder {
    
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
