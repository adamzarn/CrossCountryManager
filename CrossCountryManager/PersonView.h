//
//  PersonView.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonViewDelegate.h"

@interface PersonView: UIView {
    
}

@property (weak) id <PersonViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *email2TextField;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *runnerGender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *runnerTeam;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

-(void)customInit;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
