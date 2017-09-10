//
//  SavedRaceCell.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "SavedRaceCell.h"
#import "AppDelegate.h"

@interface SavedRaceCell ()

@end

@implementation SavedRaceCell {
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setUpCell:(RaceClass *)currentRace quickView:(BOOL)quickView {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!quickView) {
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    self.meetLabel.text = currentRace.meet;
    
    if ([currentRace.status isEqualToString:@"pending"]) {
        self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@ miles - Pending",currentRace.group,currentRace.distance];
        self.backgroundColor = appDelegate.lightBlue;
        [self setTintColor: [UIColor whiteColor]];
        self.meetLabel.textColor = [UIColor whiteColor];
        self.detailLabel.textColor = [UIColor whiteColor];
    } else {
        self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@ miles - Finished",currentRace.group,currentRace.distance];
        self.backgroundColor = nil;
        [self setTintColor:appDelegate.darkBlue];
        self.meetLabel.textColor = appDelegate.darkBlue;
        self.detailLabel.textColor = appDelegate.darkBlue;
    }

}

@end

