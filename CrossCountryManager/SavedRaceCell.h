//
//  SavedRaceCell.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaceClass.h"

@interface SavedRaceCell : UITableViewCell {
    
}
@property (weak, nonatomic) IBOutlet UILabel *meetLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapsLabel;

- (void) setUpCell:(RaceClass *)currentRace quickView:(BOOL)quickView;

@end
