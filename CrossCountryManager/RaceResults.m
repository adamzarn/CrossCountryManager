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

@interface RaceResults ()

@end

@implementation RaceResults {
    NSArray *sortedResults;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    [self update];
    
    if (self.comingFromLogRace) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(pop)];
        self.navigationItem.hidesBackButton = YES;
        self.navigationItem.leftBarButtonItem = item;
    }
    
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

//IBActions***************************************************************************************************

- (IBAction)emailButtonPressed:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        
        NSMutableString *messageBody = [[NSMutableString alloc] init];
        int i = 1;
        for (ResultClass *result in sortedResults) {
            if (i==1) {
                messageBody = [NSMutableString stringWithFormat:@"1. %@ - %@ (%@ per mile) %@",result.name,result.time,result.pace,result.laps];
            } else {
                messageBody = [NSMutableString stringWithFormat:@"%@\n\n%d. %@ - %@ (%@ per mile) %@",messageBody,i,result.name,result.time,result.pace,result.laps];
            }
            i++;
        }
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        for (ResultClass *result in sortedResults) {
            [recipients addObject:result.email];
            [recipients addObject:result.email2];
        }
        
        [mail setSubject: [NSString stringWithFormat:@"%@ Meet Results - %@ - %@ miles",appDelegate.meet,appDelegate.group,appDelegate.distance]];
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

- (void)pop {
    [self.navigationController popToRootViewControllerAnimated:true];
 }

-(void) update {
    NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRace = %@" predArray:[NSArray arrayWithObjects: self.race, nil] context:context];
    self.results = [results mutableCopy];
    sortedResults = [self.results sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"time"]];
    UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:[NSString stringWithFormat:@"%@ - %@ miles",appDelegate.group,appDelegate.distance] bottomLine:[NSString stringWithFormat:@"At %@ on %@",appDelegate.meet,appDelegate.dateString]];
    
    self.navigationItem.titleView = twoLineTitleView;
}

@end

