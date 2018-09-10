//
//  PersonView.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import "PersonView.h"

@interface PersonView()
@property (strong, nonatomic) IBOutlet UIView *contentView;
@end

@implementation PersonView

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customInit];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

-(void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"PersonView" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

- (IBAction)saveButtonPressed:(id)sender {
    [self.delegate didPressSave];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate didPressCancel];
}

@end
