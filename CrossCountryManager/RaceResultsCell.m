//
//  RaceResultsCell.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/20/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RaceResultsCell.h"
#import "LogRace.h"
#import "ResultClass.h"
#import "GlobalFunctions.h"
#import "RunnerClass.h"

@interface RaceResultsCell ()

@end

@implementation RaceResultsCell {
    NSManagedObjectContext *context;
}

-(void)setUpCell:(ResultClass *)currentResult currentRunner:(RunnerClass *)currentRunner row:(NSInteger)row {
    
    self.runnerImageView.clipsToBounds = YES;
    
    switch (row) {
        case 0:
            self.medalButton.backgroundColor = [UIColor colorWithRed: 212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:1.0];
            [self.medalButton setTitle:@"G" forState:UIControlStateNormal];
            break;
        case 1:
            self.medalButton.backgroundColor = [UIColor colorWithRed: 168.0/255.0 green:168.0/255.0 blue: 168.0/255.0 alpha:1.0];
            [self.medalButton setTitle:@"S" forState:UIControlStateNormal];
            break;
        case 2:
            self.medalButton.backgroundColor = [UIColor colorWithRed: 150.0/255.0 green:90.0/255.0 blue: 56.0/255.0 alpha:1.0];
            [self.medalButton setTitle:@"B" forState:UIControlStateNormal];
            break;
        default:
            self.medalButton.backgroundColor = [UIColor clearColor];
            break;
    }
    
    self.nameLabel.text = currentResult.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@ per mile",currentResult.time,currentResult.pace];
    
    self.lapLabel.text = [GlobalFunctions getLapString:currentResult.lap1 lap2:currentResult.lap2 lap3:currentResult.lap3];
    
    self.medalButton.layer.cornerRadius = 15;
    self.medalButton.layer.zPosition = 1;
    self.medalButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.medalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.runnerImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.runnerImageView.layer.borderWidth = 1;
    
    self.runnerImageView.image = nil;
    
    NSString *fullPath = [GlobalFunctions getFullPath:currentRunner.fileName];

    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (currentRunner.fileName != nil) {
        if ([manager fileExistsAtPath:fullPath]){
            
            UIImage *originalImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                
                if ([currentRunner.photoOrientation isEqual: @"portrait"]) {
                    CGImageRef imageRef = [originalImage CGImage];
                    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        self.runnerImageView.image = rotatedImage;
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        self.runnerImageView.image = originalImage;
                    });
                }
            });
        } else if ([currentRunner.gender isEqualToString:@"Boy"]) {
            self.runnerImageView.image = [UIImage imageNamed:@"Boy.png"];
        } else {
            self.runnerImageView.image = [UIImage imageNamed:@"Girl.png"];
        }
    }

    
    
}

@end
