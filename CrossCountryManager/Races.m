//
//  Races.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "Races.h"
#import "RaceClass.h"
#import "RaceCell.h"
#import "AppDelegate.h"
#import "SavedRaceCell.h"
#import "RaceResults.h"
#import "RunnerOrder.h"
#import "RaceClass.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"
#import "RemoveAds.h"
@import GoogleMobileAds;

@interface Races ()

@end

@implementation Races {
    NSMutableArray *allRaces;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    UIView *dimView;
    UIPickerView *pickerView;
    UITextField *firstResponder;
    NSMutableArray *distanceOptions;
    NSIndexPath *indexPathBeingEdited;
    NSMutableArray *racesByDate;
    NSMutableArray *sortedDateArray;
    NSMutableArray *sortedArray;
    UIBarButtonItem *addButton;
    NSString *uneditedRaceDistance;
    NSString *uneditedMeetName;
    NSInteger uneditedGenderIndex;
    NSInteger uneditedTeamIndex;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    self.racesSegment.tintColor = appDelegate.darkBlue;
    self.createRaceTitle.textColor = appDelegate.darkBlue;
    
    dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.5f];
    [self.genderSegment setTitle:@"All" forSegmentAtIndex:0];
    [self.genderSegment setTitle:@"Boys" forSegmentAtIndex:1];
    [self.genderSegment setTitle:@"Girls" forSegmentAtIndex:2];
    [self.teamSegment setTitle:@"All" forSegmentAtIndex:0];
    [self.teamSegment setTitle:@"Varsity" forSegmentAtIndex:1];
    [self.teamSegment setTitle:@"Junior Varsity" forSegmentAtIndex:2];
    
    self.genderSegment.tintColor = appDelegate.darkBlue;
    self.teamSegment.tintColor = appDelegate.darkBlue;
    
    self.raceView.hidden = YES;
    self.raceView.layer.cornerRadius = 5;
    self.raceView.userInteractionEnabled = NO;
    
    self.meetTextField.delegate = self;
    self.distanceTextField.delegate = self;
    
    self.meetTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    distanceOptions = [[NSMutableArray alloc] init];
    
    int i = 0;
    while (i <= 9) {
        int j = 0;
        while (j <= 9) {
            NSString *numberString = [NSString stringWithFormat: @"%d.%d%d",i,j,0];
            if (![numberString isEqual:@"0.00"]) {
                [distanceOptions addObject:numberString];
            }
            NSString *numberString2 = [NSString stringWithFormat: @"%d.%d%d",i,j,5];
            if (![numberString2 isEqual:@"0.00"]) {
                [distanceOptions addObject:numberString2];
            }
            j++;
        }
        i++;
    }
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                 target:self
                 action:@selector(createRace:)];
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:addButton, nil];
    
    dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.5f];
    
    [self.createRaceButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismissPickerView:)];
    toolBar.items = @[flex, barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    barButtonDone.style = UIBarButtonItemStyleDone;
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height, screenWidth, 200)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolBar.frame.size.height + pickerView.frame.size.height)];
    inputView.backgroundColor = [UIColor clearColor];
    [inputView addSubview:pickerView];
    [inputView addSubview:toolBar];
    
    self.distanceTextField.inputView = inputView;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:appDelegate.darkBlue}];
    [self.navigationController.navigationBar setTintColor:appDelegate.darkBlue];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tabBarController.tabBar setTintColor:appDelegate.darkBlue];
    appDelegate.myTabBarController = self.tabBarController;
    appDelegate.racesNavigationController = self.navigationController;

}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    self.myTableView.tableHeaderView.frame = bannerView.frame;
    self.myTableView.tableHeaderView = bannerView;
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
}

- (void)viewWillAppear:(BOOL)animated {
    NSInteger racesSegmentSelectedIndex = [NSUserDefaults.standardUserDefaults integerForKey:@"racesSegmentSelectedIndex"];
    [self.racesSegment setSelectedSegmentIndex:racesSegmentSelectedIndex];
    self.aiv.hidden = false;
    [self.aiv startAnimating];
    self.myTableView.hidden = true;
    [self updateData];
    self.aiv.hidden = true;
    [self.aiv stopAnimating];
    self.myTableView.hidden = false;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"paid"]) {
        
        self.bannerView = [[GADBannerView alloc]
                           initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.delegate = self;
        
        self.bannerView.adUnitID = @"ca-app-pub-4590926477342036/9773370012";
        self.bannerView.rootViewController = self;
        
        GADRequest *request = [GADRequest request];
        [self.bannerView loadRequest:request];
        
    } else {
        self.removeAdsButton.enabled = false;
        self.removeAdsButton.tintColor = [UIColor clearColor];
        self.myTableView.tableHeaderView = nil;
    }
    
}

//UITableViewDelegate Methods*********************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.racesSegment.selectedSegmentIndex == 0) {
        return [[racesByDate objectAtIndex:section] count];
    }
    return [sortedArray count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.racesSegment.selectedSegmentIndex == 0) {
        return [racesByDate count];
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.racesSegment.selectedSegmentIndex == 0) {
        return [sortedArray objectAtIndex:section];
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    SavedRaceCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    RaceClass *currentRace = [[RaceClass alloc] init];
    if (self.racesSegment.selectedSegmentIndex == 0) {
        currentRace = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        currentRace = [sortedArray objectAtIndex:indexPath.row];
    }
    [cell setUpCell:currentRace quickView:false];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RaceClass *selectedRace = [[RaceClass alloc] init];
    NSManagedObject *selectedRaceMO = [[NSManagedObject alloc] init];
    
    if (self.racesSegment.selectedSegmentIndex == 0) {
        selectedRace = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        selectedRaceMO = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    } else {
        selectedRace = [sortedArray objectAtIndex:indexPath.row];
        selectedRaceMO = [sortedArray objectAtIndex:indexPath.row];
    }
    
    if ([selectedRace.status isEqualToString:@"pending"]) {
        
        RunnerOrder *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RunnerOrder"];
        vc.runnerOrder = selectedRace.runnerOrder;
        vc.savedRace = selectedRaceMO;
        
        NSString *indices = [self getIndicesFromGroup:selectedRace.group];
        
        NSInteger genderIndex = [self getGenderIndex:indices];
        NSInteger teamIndex = [self getTeamIndex:indices];
        
        vc.predicate = [self getPredicate:genderIndex t:teamIndex];
        
        [self.navigationController pushViewController:vc animated:true];
        
    } else {
    
        RaceResults *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RaceResults"];
    
        vc.comingFromLogRace = NO;
        vc.savedRace = selectedRaceMO;
    
        [self.navigationController pushViewController:vc animated:true];
    
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Race?" message:@"Are you sure you want to continue? This will delete all of this race's results as well." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            if (self.racesSegment.selectedSegmentIndex == 0) {
                [context deleteObject:[[racesByDate objectAtIndex:indexPath.section] objectAtIndex: indexPath.row]];
            } else {
                [context deleteObject:[sortedArray objectAtIndex:indexPath.row]];
            }
            [appDelegate saveContext];
            [self updateData];
            
        }];
        
        [alert addAction:cancel];
        [alert addAction:yes];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    indexPathBeingEdited = indexPath;
    [self editRace:indexPath];
}

//UITextFieldDelegate Methods*********************************************************************************

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.distanceTextField) {
        if (![distanceOptions containsObject:textField.text] && ![textField.text isEqual: @""]) {
            [pickerView selectRow:39 inComponent:0 animated:NO];
            self.distanceTextField.text = [distanceOptions objectAtIndex:39];
        } else if (![textField.text isEqual: @""]) {
            [pickerView selectRow:[distanceOptions indexOfObject:self.distanceTextField.text] inComponent:0 animated:NO];
        } else {
            [pickerView selectRow:39 inComponent:0 animated:NO];
            self.distanceTextField.text = [distanceOptions objectAtIndex:39];
        }
    }
    [textField becomeFirstResponder];
    firstResponder = textField;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

//IBActions***************************************************************************************************

- (void)createRace:(id)sender {
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.raceView.userInteractionEnabled = YES;
    self.raceView.hidden = NO;
    [self.view bringSubviewToFront:self.raceView];
    
    self.createRaceTitle.text = @"Create Race";
    [self.createRaceButton setTitle:@"Create" forState:UIControlStateNormal];
    [self.meetTextField becomeFirstResponder];
    
}

- (IBAction)createButtonPressed:(id)sender {
    
    if ([self.meetTextField.text isEqual: @""] || [self.distanceTextField.text isEqual: @""]) {
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Missing Data." message:@"You must specify the name of the meet and the race distance." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else if ([self.createRaceTitle.text isEqual: @"Edit Name or Distance"] || [self.createRaceTitle.text isEqual: @"Edit Race"]) {
        
        RaceClass *raceToEdit = [[RaceClass alloc] init];
        if (self.racesSegment.selectedSegmentIndex == 0) {
            raceToEdit = [[racesByDate objectAtIndex:indexPathBeingEdited.section] objectAtIndex:indexPathBeingEdited.row];
        } else {
            raceToEdit = [sortedArray objectAtIndex:indexPathBeingEdited.row];
        }
        
        raceToEdit.meet = self.meetTextField.text;
        raceToEdit.distance = self.distanceTextField.text;
        
        if (self.genderSegment.selectedSegmentIndex == 0) {
            raceToEdit.gender = @"All";
        } else if (self.genderSegment.selectedSegmentIndex == 1) {
            raceToEdit.gender = @"Boys";
        } else {
            raceToEdit.gender = @"Girls";
        }
        
        if (self.teamSegment.selectedSegmentIndex == 0) {
            raceToEdit.team = @"All";
        } else if (self.teamSegment.selectedSegmentIndex == 1) {
            raceToEdit.team = @"Varsity";
        } else {
            raceToEdit.team = @"Junior Varsity";
        }
        
        raceToEdit.group = [self getGroup:self.genderSegment.selectedSegmentIndex t:self.teamSegment.selectedSegmentIndex];
        
        if (![uneditedRaceDistance isEqual: raceToEdit.distance]) {
            
            NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRace = %@" predArray: [NSArray arrayWithObjects: raceToEdit, nil] context:context];
            
            for (NSManagedObject *result in results) {
                ResultClass *currentResult = (ResultClass *)result;
                currentResult.distance = raceToEdit.distance;
                [result setValue:[GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:currentResult, nil]] forKey:@"pace"];
                [result setValue:raceToEdit.distance forKey:@"distance"];
                [result setValue:raceToEdit.meet forKey:@"meet"];
                [result setValue:raceToEdit.dateString forKey:@"dateString"];
            }
            
            [appDelegate saveContext];
            
        }
        
        if (![uneditedMeetName isEqual: raceToEdit.meet]) {
            
            NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRace = %@" predArray: [NSArray arrayWithObjects: raceToEdit, nil] context:context];
            
            for (NSManagedObject *result in results) {
                [result setValue:raceToEdit.meet forKey:@"meet"];
            }
            
            [appDelegate saveContext];
            
        }
        
        if (uneditedGenderIndex != self.genderSegment.selectedSegmentIndex || uneditedTeamIndex != self.teamSegment.selectedSegmentIndex) {
            
            raceToEdit.runnerOrder = nil;
            raceToEdit.group = [self getGroup:self.genderSegment.selectedSegmentIndex t:self.teamSegment.selectedSegmentIndex];
            
        }
        
        if (self.racesSegment.selectedSegmentIndex == 0) {
            [[racesByDate objectAtIndex:indexPathBeingEdited.section] replaceObjectAtIndex:indexPathBeingEdited.row withObject:raceToEdit];
        } else {
            [sortedArray replaceObjectAtIndex:indexPathBeingEdited.row withObject:raceToEdit];
        }
        
        [self.myTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPathBeingEdited, nil] withRowAnimation:UITableViewRowAnimationNone];
        [self dismissRaceView];
        [appDelegate saveContext];
        
    } else {
        
        RunnerOrder *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RunnerOrder"];
        
        NSInteger g = self.genderSegment.selectedSegmentIndex;
        NSInteger t = self.teamSegment.selectedSegmentIndex;
        
        NSString *group = [self getGroup:g t:t];
        vc.predicate = [self getPredicate:g t:t];
        
        NSMutableArray *runnerOrder = [[NSMutableArray alloc] init];
        
        RaceClass *newRace = [[RaceClass alloc] init:self.distanceTextField.text dateString:@"" meet:self.meetTextField.text gender:[self.genderSegment titleForSegmentAtIndex:self.genderSegment.selectedSegmentIndex] team:[self.teamSegment titleForSegmentAtIndex:self.teamSegment.selectedSegmentIndex] group:group runnerOrder:runnerOrder status:@"pending"];
        
        vc.race = newRace;
        
        self.distanceTextField.text = @"";
        [self dismissRaceView];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    self.distanceTextField.enabled = true;
    self.genderSegment.enabled = true;
    self.teamSegment.enabled = true;
    
}

- (NSString *) getGroup:(NSInteger)g t:(NSInteger)t {
    
    NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)g,(long)t];
    NSDictionary *titleLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"All Runners",@"00",
                                 @"Varsity",@"01",
                                 @"Junior Varsity",@"02",
                                 @"Boys",@"10",
                                 @"Varsity - Boys",@"11",
                                 @"Junior Varsity - Boys",@"12",
                                 @"Girls",@"20",
                                 @"Varsity - Girls",@"21",
                                 @"Junior Varsity - Girls",@"22", nil];
    
    return [titleLookup objectForKey:key];

}

- (NSString *) getPredicate:(NSInteger)g t:(NSInteger)t {
    
    NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)g,(long)t];
    
    NSDictionary *predicateLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"gender == 'Boy' OR gender == 'Girl'",@"00",
                                     @"team == 'Varsity'",@"01",
                                     @"team == 'Junior Varsity'",@"02",
                                     @"gender == 'Boy'",@"10",
                                     @"gender == 'Boy' AND team == 'Varsity'",@"11",
                                     @"gender == 'Boy' AND team == 'Junior Varsity'",@"12",
                                     @"gender == 'Girl'",@"20",
                                     @"gender == 'Girl' AND team == 'Varsity'",@"21",
                                     @"gender == 'Girl' AND team == 'Junior Varsity'",@"22", nil];
    
    return [predicateLookup objectForKey:key];

}

- (NSString *) getIndicesFromGroup:(NSString *)group {
    
    NSDictionary *titleLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"00",@"All Runners",
                                 @"01",@"Varsity",
                                 @"02",@"Junior Varsity",
                                 @"10",@"Boys",
                                 @"11",@"Varsity - Boys",
                                 @"12",@"Junior Varsity - Boys",
                                 @"20",@"Girls",
                                 @"21",@"Varsity - Girls",
                                 @"22",@"Junior Varsity - Girls", nil];
    
    return [titleLookup objectForKey:group];
    
}

- (NSInteger) getGenderIndex:(NSString *)indices {
    
    NSRange genderRange = NSMakeRange(0, 1);
    
    return [[indices substringWithRange:genderRange] integerValue];

}

- (NSInteger) getTeamIndex:(NSString *)indices {
    
    NSRange teamRange = NSMakeRange(1, 1);

    return [[indices substringWithRange:teamRange] integerValue];
    
}


- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissRaceView];
}

- (IBAction)raceSegmentValueChanged:(id)sender {
    [NSUserDefaults.standardUserDefaults setInteger:self.racesSegment.selectedSegmentIndex forKey:@"racesSegmentSelectedIndex"];
    [self updateData];
}


//Helper Methods**********************************************************************************************

-(void)updateData {
    
    NSArray *results = [GlobalFunctions getData:@"Race" context:context];
    
    allRaces = [[NSMutableArray alloc] init];
    allRaces = [results mutableCopy];
    
    if (self.racesSegment.selectedSegmentIndex == 0) {
    
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
        
    } else {
        
        sortedArray = [[NSMutableArray alloc] init];
        for (RaceClass *race in allRaces) {
            if ([race.status isEqual:@"pending"]) {
                [sortedArray addObject:race];
            }
        }
        
    }
    
    [self.myTableView reloadData];

}

- (void)dismissRaceView {
    self.raceView.hidden = YES;
    self.raceView.userInteractionEnabled = NO;
    [dimView removeFromSuperview];
    self.meetTextField.text = @"";
    [self.genderSegment setSelectedSegmentIndex:0];
    [self.teamSegment setSelectedSegmentIndex:0];
    self.distanceTextField.text = @"";
    self.distanceTextField.enabled = true;
    self.genderSegment.enabled = true;
    self.teamSegment.enabled = true;
    [firstResponder resignFirstResponder];
}

- (void)editRace:(NSIndexPath *)indexPath {
    
    RaceClass *raceToEdit = [[RaceClass alloc] init];
    if (self.racesSegment.selectedSegmentIndex == 0) {
        raceToEdit = [[racesByDate objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
        self.createRaceTitle.text = @"Edit Name or Distance";
        self.genderSegment.enabled = false;
        self.teamSegment.enabled = false;
    } else {
        raceToEdit = [sortedArray objectAtIndex:indexPath.row];
        self.createRaceTitle.text = @"Edit Race";
        self.genderSegment.enabled = true;
        self.teamSegment.enabled = true;
    }
    
    self.meetTextField.text = raceToEdit.meet;
    self.distanceTextField.text = raceToEdit.distance;
    uneditedRaceDistance = raceToEdit.distance;
    uneditedMeetName = raceToEdit.meet;
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.raceView.userInteractionEnabled = YES;
    self.raceView.hidden = NO;
    [self.view bringSubviewToFront:self.raceView];
    
    [self.createRaceButton setTitle:@"Save" forState:UIControlStateNormal];
    
    [self.meetTextField becomeFirstResponder];
    
    NSString *indices = [self getIndicesFromGroup:raceToEdit.group];
    
    NSInteger genderIndex = [self getGenderIndex:indices];
    NSInteger teamIndex = [self getTeamIndex:indices];
    
    self.genderSegment.selectedSegmentIndex = genderIndex;
    self.teamSegment.selectedSegmentIndex = teamIndex;
    
    uneditedGenderIndex = genderIndex;
    uneditedTeamIndex = teamIndex;
    
}

//UIPickerViewDelegate Methods********************************************************************************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [distanceOptions count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [distanceOptions objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.distanceTextField.text = [distanceOptions objectAtIndex:row];
}

-(void)dismissPickerView:(id)sender {
    [firstResponder resignFirstResponder];
}

- (IBAction)removeAdsButtonPressed:(id)sender {
    RemoveAds *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RemoveAds"];
    [self.navigationController pushViewController:vc animated:true];
}

@end

