//
//  RaceCell.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/19/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogRace.h"

@interface RaceCell : UITableViewCell {

}

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (weak, nonatomic) IBOutlet UIButton *lapButton;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lap1Label;
@property (weak, nonatomic) IBOutlet UILabel *lap2Label;
@property (weak, nonatomic) IBOutlet UILabel *lap3Label;

@property BOOL updateTime;
@property NSString *finishButtonTitle;
@property UIColor *finishButtonColor;
@property UIColor *finishButtonTextColor;
@property NSString *lapButtonTitle;
@property UIColor *lapButtonColor;
@property UIColor *lapButtonTextColor;
@property LogRace *delegate;

-(void)setUpCell:(NSString *)name currentlyRunning:(NSString *)currentlyRunning currentTime:(NSString *)currentTime startButtonPressed:(BOOL)startButtonPressed lap1:(NSString *)lap1 lap2:(NSString *)lap2 lap3:(NSString *)lap3;

- (IBAction)lapButtonPressed:(id)sender;

- (IBAction)finishButtonPressed:(id)sender;

@end
