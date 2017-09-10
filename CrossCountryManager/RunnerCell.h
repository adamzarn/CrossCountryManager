//
//  RunnerCell.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/18/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Runners.h"
#import "RunnerClass.h"

@interface RunnerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *runnerImageView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addPhotoLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiv;
@property Runners *delegate;
@property RunnerClass *runner;

- (void) setUpCell:(RunnerClass *)currentRunner;
- (IBAction)addPhotoButtonPressed:(id)sender;

@end

