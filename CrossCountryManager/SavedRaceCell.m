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
    
    self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@ miles",currentRace.group,currentRace.distance];
    [self setTintColor:appDelegate.darkBlue];
    self.meetLabel.textColor = appDelegate.darkBlue;
    self.detailLabel.textColor = appDelegate.darkBlue;

}

@end

