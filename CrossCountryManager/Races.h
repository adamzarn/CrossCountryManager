//
//  Races.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/21/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Races : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *createRaceButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UITextField *meetTextField;
@property (weak, nonatomic) IBOutlet UITextField *distanceTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *teamSegment;
@property (weak, nonatomic) IBOutlet UIView *raceView;
@property (weak, nonatomic) IBOutlet UILabel *createRaceTitle;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiv;

-(void)createRace:(id)sender;

@end
