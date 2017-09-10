//
//  RaceResultsCell.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultClass.h"
#import "RunnerClass.h"

@interface RaceResultsCell : UITableViewCell {
    
}

@property (weak, nonatomic) IBOutlet UIButton *medalButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *lapLabel;
@property (weak, nonatomic) IBOutlet UIImageView *runnerImageView;

-(void)setUpCell:(ResultClass *)currentResult currentRunner:(RunnerClass *)currentRunner row:(NSInteger)row;

@end
