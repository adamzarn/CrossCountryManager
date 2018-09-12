//
//  RaceResults.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "LogRace.h"
#import "RaceResults.h"
#import "RaceResultsCell.h"
#import "AddResultCell.h"
#import "RunnerClass.h"
#import "CoachClass.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"
#import "AppDelegate.h"
@import GoogleMobileAds;

@interface RaceResults ()

@end

@implementation RaceResults {
    NSArray *sortedResults;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    NSIndexPath *indexPathBeingEdited;
    UIView *dimView;
    UIPickerView *namePickerView;
    UIPickerView *timePickerView;
    UITextField *firstResponder;
    NSMutableArray *eligibleRunners;
    CGFloat screenWidth;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    eligibleRunners = [[NSMutableArray alloc] init];
    
    dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.5f];
    
    self.editResultView.hidden = YES;
    self.editResultView.layer.cornerRadius = 5;
    self.editResultView.userInteractionEnabled = NO;
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    [self update];
    
    if (self.comingFromLogRace) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Races" style:UIBarButtonItemStylePlain target:self action:@selector(backToRaces)];
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = item;
    }
    
    self.pickerOptions = [[NSMutableArray alloc] init];
    
    int i = 0;
    while (i <= 5) {
        int j = 0;
        while (j <= 9) {
            NSString *numberString = [NSString stringWithFormat: @"%d%d",i,j];
            [self.pickerOptions addObject:numberString];
            j++;
        }
        i++;
    }
    
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIView *nameInputView = [self createNameInputView];
    self.nameTextField.inputView = nameInputView;
    
    UIView *timeInputView = [self createTimeInputView];
    self.timeTextField.inputView = timeInputView;
    self.lap1TextField.inputView = timeInputView;
    self.lap2TextField.inputView = timeInputView;
    self.lap3TextField.inputView = timeInputView;
    
    self.saveResultButton.tintColor = appDelegate.darkBlue;
    self.cancelButton.tintColor = appDelegate.darkBlue;
    self.editResultLabel.textColor = appDelegate.darkBlue;
    
}

-(UIToolbar *)createDoneToolbar {
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismissPickerView:)];
    toolbar.items = @[flex, barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    return toolbar;
}

-(UIView *)createNameInputView {
    UIToolbar *toolbar = [self createDoneToolbar];
    
    namePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, screenWidth, 150)];
    namePickerView.delegate = self;
    namePickerView.dataSource = self;
    namePickerView.showsSelectionIndicator = YES;
    
    UIView *nameInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 244)];
    nameInputView.backgroundColor = [UIColor clearColor];
    
    [nameInputView addSubview:namePickerView];
    [nameInputView addSubview:toolbar];
    
    return nameInputView;
    
}

-(UIView *)createTimeInputView {
    UIToolbar *toolbar = [self createDoneToolbar];

    UILabel *labelMinutes = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                      toolbar.frame.size.height,
                                                                      screenWidth/2,
                                                                      44)];
    [labelMinutes setText:@"Minutes"];
    [labelMinutes setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *labelSeconds = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2,
                                                                      toolbar.frame.size.height,
                                                                      screenWidth/2,
                                                                      44)];
    [labelSeconds setText:@"Seconds"];
    [labelSeconds setTextAlignment:NSTextAlignmentCenter];
    
    timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height + labelMinutes.frame.size.height, screenWidth, 150)];
    timePickerView.delegate = self;
    timePickerView.dataSource = self;
    timePickerView.showsSelectionIndicator = YES;
    
    UIView *timeInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbar.frame.size.height + labelMinutes.frame.size.height + timePickerView.frame.size.height)];
    timeInputView.backgroundColor = [UIColor clearColor];
    
    [timeInputView addSubview:timePickerView];
    [timeInputView addSubview:labelMinutes];
    [timeInputView addSubview:labelSeconds];
    [timeInputView addSubview:toolbar];
    
    return timeInputView;
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"paid"]) {
        
        self.bannerView = [[GADBannerView alloc]
                           initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.delegate = self;
        
        self.bannerView.adUnitID = @"ca-app-pub-4590926477342036/1771181941";
        self.bannerView.rootViewController = self;
        
        GADRequest *request = [GADRequest request];
        [self.bannerView loadRequest:request];
        
    } else {
        self.myTableView.tableHeaderView = nil;
    }
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    self.myTableView.tableHeaderView.frame = bannerView.frame;
    self.myTableView.tableHeaderView = bannerView;
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
}

//UITableViewDelegate Methods*********************************************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sortedResults count] + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < sortedResults.count) {
    
        static NSString *reuseID = @"SimpleTableItem";
        
        RaceResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
        
        ResultClass *currentResult = [sortedResults objectAtIndex:indexPath.row];
        RunnerClass *currentRunner = [GlobalFunctions getCurrentRunner:currentResult.name context:context];
        
        [cell setUpCell:currentResult currentRunner:currentRunner row:indexPath.row];
        
        return cell;
        
    } else {
        
        static NSString *reuseID = @"AddResultItem";
        
        AddResultCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
        
        return cell;
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    if (indexPath.row == sortedResults.count) {
        [self addResult:indexPath];
    } else {
        indexPathBeingEdited = indexPath;
        [self editResult:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row < sortedResults.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Result?" message:@"Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
            [self->context deleteObject:[self->sortedResults objectAtIndex:indexPath.row]];
            [self->appDelegate saveContext];
            [self update];
            [self.myTableView reloadData];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:yes];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)setEligibleRunners {
    NSString *group = [self.savedRace valueForKey:@"group"];
    NSString *indices = [GlobalFunctions getIndicesFromGroup:group];
    NSString *predicate = [GlobalFunctions getPredicate:indices];
    NSArray *allRunners = [GlobalFunctions getData:@"Runner" pred:predicate context:context];
    [eligibleRunners removeAllObjects];
    BOOL found = NO;
    for (RunnerClass *runner in allRunners) {
        for (ResultClass *result in sortedResults) {
            if ([runner.name isEqualToString: result.name]) {
                found = YES;
            }
        }
        if (!found) {
            [eligibleRunners addObject:runner];
        }
        found = NO;
    }
}

- (void)editResult:(NSIndexPath *)indexPath {
    
    self.editResultLabel.text = @"Edit Result";
    
    [self setEligibleRunners];
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.editResultView.userInteractionEnabled = YES;
    self.editResultView.hidden = NO;
    [self.view bringSubviewToFront:self.editResultView];
    
    [self.timeTextField becomeFirstResponder];
    
    ResultClass *resultToEdit = [sortedResults objectAtIndex:indexPath.row];
    self.nameTextField.text = resultToEdit.name;
    self.nameTextField.userInteractionEnabled = NO;
    self.nameTextField.enabled = NO;
    self.timeTextField.text = resultToEdit.time;
    self.lap1TextField.text = resultToEdit.lap1;
    self.lap2TextField.text = resultToEdit.lap2;
    self.lap3TextField.text = resultToEdit.lap3;
    
    [self scrollPicker:resultToEdit.time];
    
}

- (void)addResult:(NSIndexPath *)indexPath {
    
    self.editResultLabel.text = @"Add Result";
    
    [self setEligibleRunners];
    
    if (eligibleRunners.count == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Eligible Runners" message:@"Every eligible runner already has a result." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.editResultView.userInteractionEnabled = YES;
    self.editResultView.hidden = NO;
    [self.view bringSubviewToFront:self.editResultView];
    
    [self.nameTextField becomeFirstResponder];
    
    self.nameTextField.text = @"";
    self.nameTextField.userInteractionEnabled = YES;
    self.nameTextField.enabled = YES;
    self.timeTextField.text = @"";
    self.lap1TextField.text = @"";
    self.lap2TextField.text = @"";
    self.lap3TextField.text = @"";
    
}

- (IBAction)saveResultButtonPressed:(id)sender {
    
    if ([self.nameTextField.text isEqualToString:@""] || [self.timeTextField.text isEqualToString:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Data" message:@"Every result must have at least a name and a time." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];

        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if ([self.editResultLabel.text isEqualToString:@"Edit Result"]) {
    
        NSManagedObject *resultToEdit = [sortedResults objectAtIndex:indexPathBeingEdited.row];
        [resultToEdit setValue:self.timeTextField.text forKey:@"time"];
        [resultToEdit setValue:self.lap1TextField.text forKey:@"lap1"];
        [resultToEdit setValue:self.lap2TextField.text forKey:@"lap2"];
        [resultToEdit setValue:self.lap3TextField.text forKey:@"lap3"];
        
        NSString *pace = [GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:resultToEdit,nil]];
        [resultToEdit setValue:pace forKey:@"pace"];
        
        [appDelegate saveContext];
        sortedResults = [self.results sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"time"]];
        [self.myTableView reloadData];
        
    } else {
        
        NSManagedObject *resultToAdd = [NSEntityDescription insertNewObjectForEntityForName:@"Result" inManagedObjectContext:context];
        [resultToAdd setValue:self.nameTextField.text forKey:@"name"];
        [resultToAdd setValue:self.timeTextField.text forKey:@"time"];
        [resultToAdd setValue:self.lap1TextField.text forKey:@"lap1"];
        [resultToAdd setValue:self.lap2TextField.text forKey:@"lap2"];
        [resultToAdd setValue:self.lap3TextField.text forKey:@"lap3"];
        [resultToAdd setValue:[self.savedRace valueForKey:@"distance"] forKey:@"distance"];
        [resultToAdd setValue:[self.savedRace valueForKey:@"dateString"] forKey:@"dateString"];
        [resultToAdd setValue:[self.savedRace valueForKey:@"meet"] forKey:@"meet"];
        [resultToAdd setValue:self.savedRace forKey:@"resultToRace"];
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", self.nameTextField.text];
        NSArray *filteredArray = [eligibleRunners filteredArrayUsingPredicate:predicate];
        NSManagedObject *currentRunner = [filteredArray objectAtIndex:0];
        [resultToAdd setValue:currentRunner forKey:@"resultToRunner"];
        
        NSString *pace = [GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:resultToAdd,nil]];
        [resultToAdd setValue:pace forKey:@"pace"];
        
        [appDelegate saveContext];
        [self setSortedResults];
        [self.myTableView reloadData];
        
    }
    
    [self dismissEditResultView];

}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissEditResultView];
}

- (void)dismissEditResultView {
    self.editResultView.hidden = YES;
    self.editResultView.userInteractionEnabled = NO;
    [dimView removeFromSuperview];
}

//IBActions***************************************************************************************************

- (IBAction)emailButtonPressed:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        
        NSMutableString *messageBody = [[NSMutableString alloc] init];
        int i = 1;
        for (ResultClass *result in sortedResults) {
            
            NSString *laps = [GlobalFunctions getLapString:result.lap1 lap2:result.lap2 lap3:result.lap3];
            
            if (i==1) {
                messageBody = [NSMutableString stringWithFormat:@"1. %@ - %@ (%@ per mile)\n%@",result.name,result.time,result.pace,laps];
            } else {
                messageBody = [NSMutableString stringWithFormat:@"%@\n\n%d. %@ - %@ (%@ per mile)\n%@",messageBody,i,result.name,result.time,result.pace,laps];
            }
            i++;
        }
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        
        // Add coaches emails
        NSArray *coaches = [GlobalFunctions getData:@"Coach" context:context];
        for (CoachClass *coach in coaches) {
            if (![coach.email  isEqual: @""]) {
                [recipients addObject: coach.email];
            }
            if (![coach.email2  isEqual: @""]) {
                [recipients addObject: coach.email2];
            }
        }
        
        // Add parents emails
        for (ResultClass *result in sortedResults) {
            RunnerClass *currentRunner = [GlobalFunctions getCurrentRunner:result.name context:context];
            if (![currentRunner.email  isEqual: @""]) {
                [recipients addObject: currentRunner.email];
            }
            if (![currentRunner.email2  isEqual: @""]) {
                [recipients addObject: currentRunner.email2];
            }
        }
        
        [mail setSubject: [NSString stringWithFormat:@"%@ Meet Results - %@ - %@ miles - %@",[self.savedRace valueForKey:@"meet"],[self.savedRace valueForKey:@"group"],[self.savedRace valueForKey:@"distance"],[self.savedRace valueForKey:@"dateString"]]];
        [mail setMessageBody:messageBody isHTML:NO];
        [mail setToRecipients:recipients];
        
        [self presentViewController:mail animated:YES completion:NULL];
    } else {
        NSLog(@"This device cannot send email");
    }
}

//MFMailComposeViewControllerDelegate Methods*****************************************************************

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:true completion:nil];
}

//Helper Methods**********************************************************************************************

- (void)backToRaces {
    [self.navigationController dismissViewControllerAnimated:true completion:false];
    appDelegate.myTabBarController.selectedIndex = 0;
    [appDelegate.racesNavigationController popToRootViewControllerAnimated:false];
 }

-(void) update {
    [self setSortedResults];
    UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:[NSString stringWithFormat:@"%@ - %@ miles",[self.savedRace valueForKey:@"group"],[self.savedRace valueForKey:@"distance"]] bottomLine:[NSString stringWithFormat:@"At %@ on %@",[self.savedRace valueForKey:@"meet"],[self.savedRace valueForKey:@"dateString"]]];
    
    self.navigationItem.titleView = twoLineTitleView;
}

-(void) setSortedResults {
    NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRace = %@" predArray:[NSArray arrayWithObjects: self.savedRace, nil] context:context];
    self.results = [results mutableCopy];
    sortedResults = [self.results sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"time"]];
}

//UIPickerViewDelegate Methods********************************************************************************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == namePickerView) {
        return 1;
    }
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == namePickerView) {
        return eligibleRunners.count + 1;
    }
    return self.pickerOptions.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == namePickerView) {
        if (row == 0) {
            return @"";
        }
        RunnerClass *currentRunner = [eligibleRunners objectAtIndex:row - 1];
        return currentRunner.name;
    }
    return [self.pickerOptions objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == namePickerView) {
        if (row == 0) {
            firstResponder.text = @"";
            return;
        }
        RunnerClass *currentRunner = [eligibleRunners objectAtIndex:row - 1];
        firstResponder.text = currentRunner.name;
        return;
    }
    
    NSString *minutes = [self.pickerOptions objectAtIndex:[pickerView selectedRowInComponent:0]];
    NSString *seconds = [self.pickerOptions objectAtIndex:[pickerView selectedRowInComponent:1]];
    
    NSString *time = [NSString stringWithFormat:@"%@:%@",minutes,seconds];
    if ([time isEqualToString:@"00:00"]) {
        firstResponder.text = @"";
    } else {
        firstResponder.text = time;
    }

}

-(void)dismissPickerView:(id)sender {
    [firstResponder resignFirstResponder];
}

//UITextFieldDelegate Methods*********************************************************************************

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField != _nameTextField) {
        if (![textField.text isEqual: @""]) {
            [self scrollPicker:textField.text];
        } else {
           [self scrollPicker:@"00:00"];
        }
    }

    [textField becomeFirstResponder];
    firstResponder = textField;
}

-(void) scrollPicker:(NSString *)time {

    NSRange secondsRange = NSMakeRange(3, 2);
    NSRange minutesRange = NSMakeRange(0, 2);
    
    NSString *seconds = [time substringWithRange:secondsRange];
    NSString *minutes = [time substringWithRange:minutesRange];
    
    [timePickerView selectRow:[self.pickerOptions indexOfObject:minutes] inComponent:0 animated:NO];
    [timePickerView selectRow:[self.pickerOptions indexOfObject:seconds] inComponent:1 animated:NO];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end

