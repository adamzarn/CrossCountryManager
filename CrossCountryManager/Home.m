//
//  Home.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "Home.h"
#import "HomeCell.h"
#import "AppDelegate.h"

@interface Home ()

@end

@implementation Home {
    CGFloat tableViewHeight;
    CGFloat tableViewWidth;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat yShift = statusBarHeight + navBarHeight;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    tableViewWidth = [[UIScreen mainScreen] bounds].size.width;
    tableViewHeight = screenHeight - statusBarHeight - navBarHeight;
    
    self.myTableView.frame = CGRectMake(0.0, yShift, tableViewHeight, tableViewWidth);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:appDelegate.darkBlue}];
    [self.navigationController.navigationBar setTintColor:appDelegate.darkBlue];
    self.navigationController.navigationBar.translucent = NO;
    
}

//UITableViewDelegate Methods*********************************************************************************

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.tag = indexPath.row;
    
    [cell setUpCell:tableViewHeight tableViewWidth:tableViewWidth];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewHeight/2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        Runners *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Runners"];
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        Races *viewController = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"Races"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}

- (IBAction)helpButtonPressed:(id)sender {
    UIAlertController* contact = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [contact addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    [contact addAction:[UIAlertAction actionWithTitle:@"Visit App Site" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://sites.google.com/site/crosscountrymanagerapp/"] options:@{} completionHandler:nil];
    }]];
    [contact addAction:[UIAlertAction actionWithTitle:@"Email Developer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            
            NSMutableArray *recipients = [[NSMutableArray alloc] init];
            [recipients addObject:@"adam.zarn@my.wheaton.edu"];
            [mail setToRecipients:recipients];
            [mail setSubject:@"Cross Country Manager"];
            
            [self.view.window.rootViewController presentViewController:mail animated:YES completion:NULL];
        } else {
            NSLog(@"This device cannot send email");
        }
    }]];
    
    [self presentViewController:contact animated:true completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:false completion:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
    
    switch (result) {
        case MFMailComposeResultSent:
            alert.message = @"Message Sent. Your issue will be addressed soon.";
            break;
        case MFMailComposeResultFailed:
            alert.message = @"Your message failed to send. Please try again.";
            break;
        default:
            break;
        }
    
    if (!(alert.message == nil)) {
        [self presentViewController:alert animated:false completion:nil];
    }
    
}

@end
