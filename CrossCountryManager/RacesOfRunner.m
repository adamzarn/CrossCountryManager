//
//  RacesOfRunner.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RacesOfRunner.h"
#import "GlobalFunctions.h"
#import "AppDelegate.h"

@interface RacesOfRunner ()

@end

@implementation RacesOfRunner {
    NSArray *homeArray;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    
    [self update];
    
}

//UITableViewDelegate Methods*********************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    SavedRaceCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    ResultClass *currentResult = [self.results objectAtIndex:indexPath.row];
    
    cell.meetLabel.text = currentResult.meet;
    cell.detailLabel.text = [NSString stringWithFormat:@"%@ miles in %@ - %@ per mile",currentResult.distance,currentResult.time,currentResult.pace];
    cell.dateLabel.text = currentResult.dateString;
    cell.lapsLabel.text = [GlobalFunctions getLapString:currentResult.lap1 lap2:currentResult.lap2 lap3:currentResult.lap3];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Race?" message:@"Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            [self->context deleteObject:[self.results objectAtIndex:indexPath.row]];
            [self->appDelegate saveContext];
            [self update];
            [self.myTableView reloadData];
            
        }];
        
        [alert addAction:cancel];
        [alert addAction:yes];

        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

//Helper Methods**********************************************************************************************

-(void) update {
    self.results = [[GlobalFunctions getData:@"Result" pred:@"resultToRunner = %@" predArray:self.predArray context:context] mutableCopy];
    NSString *raceCount = [NSString stringWithFormat:@"%lu races", (unsigned long)[self.results count]];
    if ([self.results count] == 1) {
        raceCount = @"1 race";
    }

    NSMutableArray *uniqueDates = [[NSMutableArray alloc] init];
    for (ResultClass *result in self.results) {
        if (![uniqueDates containsObject: result.dateString]) {
            [uniqueDates addObject:result.dateString];
        }
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"M/d/yyyy"];
    NSMutableArray *sortedDateArray = [[NSMutableArray alloc] init];
    for (NSString *dateString in uniqueDates) {
        NSDate *date = [dateFormat dateFromString:dateString];
        [sortedDateArray addObject:date];
    }
    
    [sortedDateArray sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSDate *date in sortedDateArray) {
        for (ResultClass *result in self.results) {
            if ([result.dateString isEqual: [dateFormat stringFromDate:date]]) {
                [tempArray addObject: result];
            }
        }
    }
    
    self.results = tempArray;
    
    UIView *twoLineTitleView = [GlobalFunctions configureTwoLineTitleView:self.name bottomLine:[NSString stringWithFormat:@"%@ - %@ per mile",raceCount,[GlobalFunctions getAverageMileTime:self.results]]];
    self.navigationItem.titleView = twoLineTitleView;
}

//IBActions***************************************************************************************************


- (IBAction)emailButtonPressed:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        
        NSMutableString *messageBody = [[NSMutableString alloc] init];
        int i = 1;
        for (ResultClass *result in self.results) {
            if (i==1) {
                messageBody = [NSMutableString stringWithFormat:@"%@: %@ miles in %@ - %@ per mile",result.dateString,result.distance,result.time,result.pace];
            } else {
                messageBody = [NSMutableString stringWithFormat:@"%@\n%@: %@ miles in %@ - %@ per mile",messageBody,result.dateString,result.distance,result.time,result.pace];
            }
            i++;
        }
        
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        if (self.selectedRunner.email != nil) {
            [recipients addObject:self.selectedRunner.email];
        }
        if (self.selectedRunner.email2 != nil) {
            [recipients addObject:self.selectedRunner.email2];
        }
        
        [mail setSubject: [NSString stringWithFormat:@"%@ - Race Results",self.name]];
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

@end
