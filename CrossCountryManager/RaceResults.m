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
#import "RunnerClass.h"
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
    UIPickerView *myPickerView;
    UITextField *firstResponder;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    UILabel *labelMinutes = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                    toolBar.frame.size.height,
                                                                    screenWidth/2,
                                                                    44)];
    [labelMinutes setText:@"Minutes"];
    [labelMinutes setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *labelSeconds = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/2,
                                                                      toolBar.frame.size.height,
                                                                      screenWidth/2,
                                                                      44)];
    [labelSeconds setText:@"Seconds"];
    [labelSeconds setTextAlignment:NSTextAlignmentCenter];
    
    myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBar.frame.size.height + labelMinutes.frame.size.height, screenWidth, 200)];
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    myPickerView.showsSelectionIndicator = YES;
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolBar.frame.size.height + labelMinutes.frame.size.height + myPickerView.frame.size.height)];
    inputView.backgroundColor = [UIColor clearColor];
    
    [inputView addSubview:myPickerView];
    [inputView addSubview:labelMinutes];
    [inputView addSubview:labelSeconds];
    [inputView addSubview:toolBar];
    
    self.timeTextField.inputView = inputView;
    self.lap1TextField.inputView = inputView;
    self.lap2TextField.inputView = inputView;
    self.lap3TextField.inputView = inputView;
    
    self.saveResultButton.tintColor = appDelegate.darkBlue;
    self.cancelButton.tintColor = appDelegate.darkBlue;
    self.editResultLabel.textColor = appDelegate.darkBlue;
    
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
    return [sortedResults count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    RaceResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    ResultClass *currentResult = [sortedResults objectAtIndex:indexPath.row];
    RunnerClass *currentRunner = [GlobalFunctions getCurrentRunner:@"Runner" pred:@"name == %@" name:currentResult.name context:context];
    
    [cell setUpCell:currentResult currentRunner:currentRunner row:indexPath.row];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Result?" message:@"Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
            [context deleteObject:[sortedResults objectAtIndex:indexPath.row]];
            [appDelegate saveContext];
            [self update];
            [self.myTableView reloadData];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:yes];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    indexPathBeingEdited = indexPath;
    [self editResult:indexPath];
}

- (void)editResult:(NSIndexPath *)indexPath {
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.editResultView.userInteractionEnabled = YES;
    self.editResultView.hidden = NO;
    [self.view bringSubviewToFront:self.editResultView];
    
    [self.timeTextField becomeFirstResponder];
    
    ResultClass *resultToEdit = [sortedResults objectAtIndex:indexPath.row];
    self.timeTextField.text = resultToEdit.time;
    self.lap1TextField.text = resultToEdit.lap1;
    self.lap2TextField.text = resultToEdit.lap2;
    self.lap3TextField.text = resultToEdit.lap3;
    
    [self scrollPicker:resultToEdit.time];
    
}

- (IBAction)saveResultButtonPressed:(id)sender {
    
    NSManagedObject *resultToEdit = [sortedResults objectAtIndex:indexPathBeingEdited.row];
    
    [resultToEdit setValue:self.timeTextField.text forKey:@"time"];
    [resultToEdit setValue:self.lap1TextField.text forKey:@"lap1"];
    [resultToEdit setValue:self.lap2TextField.text forKey:@"lap2"];
    [resultToEdit setValue:self.lap3TextField.text forKey:@"lap3"];
    
    NSString *pace = [GlobalFunctions getAverageMileTime:[NSArray arrayWithObjects:resultToEdit,nil]];
    [resultToEdit setValue:pace forKey:@"pace"];
    
    [appDelegate saveContext];
    
    [self dismissEditResultView];
    
    sortedResults = [self.results sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"time"]];
    
    [self.myTableView reloadData];
    
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
        for (ResultClass *result in sortedResults) {
            RunnerClass *currentRunner = [GlobalFunctions getCurrentRunner:@"Runner" pred:@"name == %@" name:result.name context:context];
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
    NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRace = %@" predArray:[NSArray arrayWithObjects: self.savedRace, nil] context:context];
    self.results = [results mutableCopy];
    sortedResults = [self.results sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"time"]];
    UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:[NSString stringWithFormat:@"%@ - %@ miles",[self.savedRace valueForKey:@"group"],[self.savedRace valueForKey:@"distance"]] bottomLine:[NSString stringWithFormat:@"At %@ on %@",[self.savedRace valueForKey:@"meet"],[self.savedRace valueForKey:@"dateString"]]];
    
    self.navigationItem.titleView = twoLineTitleView;
}

//UIPickerViewDelegate Methods********************************************************************************

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerOptions count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerOptions objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
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
    
    if (![textField.text isEqual: @""]) {
        [self scrollPicker:textField.text];
    } else {
       [self scrollPicker:@"00:00"];
    }

    [textField becomeFirstResponder];
    firstResponder = textField;
}

-(void) scrollPicker:(NSString *)time {

    NSRange secondsRange = NSMakeRange(3, 2);
    NSRange minutesRange = NSMakeRange(0, 2);
    
    NSString *seconds = [time substringWithRange:secondsRange];
    NSString *minutes = [time substringWithRange:minutesRange];
    
    [myPickerView selectRow:[self.pickerOptions indexOfObject:minutes] inComponent:0 animated:NO];
    [myPickerView selectRow:[self.pickerOptions indexOfObject:seconds] inComponent:1 animated:NO];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

@end

