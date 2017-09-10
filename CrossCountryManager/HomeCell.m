//
//  HomeCell.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/26/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "HomeCell.h"
#import "AppDelegate.h"

@interface HomeCell ()

@end

@implementation HomeCell {
    
}

- (void)setUpCell:(CGFloat)tableViewHeight tableViewWidth:(CGFloat)tableViewWidth {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((tableViewWidth/2) - 50.0
                                                             , tableViewHeight/2 - 50.0
                                                             , 100.0
                                                             , 50.0)];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:26.0];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    title.textColor = appDelegate.darkBlue;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 0.0, tableViewWidth-30.0,tableViewHeight/2 - 50.0)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    if (self.tag == 0) {
        title.text = @"Runners";
        imageView.image = [UIImage imageNamed: @"RunnersFree"];
    } else {
        title.text = @"Races";
        imageView.image = [UIImage imageNamed: @"RacesFree"];
    }
    
    [self addSubview:title];
    [self addSubview:imageView];
    
}

@end
