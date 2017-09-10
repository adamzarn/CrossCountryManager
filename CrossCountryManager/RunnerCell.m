//
//  RunnerCell.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/18/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "RunnerCell.h"
#import "AppDelegate.h"
#import "GlobalFunctions.h"

@interface RunnerCell ()

@end

@implementation RunnerCell {
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    context = appDelegate.persistentContainer.viewContext;
    self.runnerImageView.layer.cornerRadius = 30;
    self.runnerImageView.clipsToBounds = YES;
    self.runnerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    [self setTintColor:appDelegate.darkBlue];
    
}

- (void)setUpCell:(RunnerClass *)currentRunner {
    
    self.nameLabel.text = currentRunner.name;
    self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@s",currentRunner.team,currentRunner.gender];
    self.aiv.hidden = true;
    
    self.addPhotoLabel.hidden = false;
    self.runnerImageView.image = nil;

    NSString *fullPath = [GlobalFunctions getFullPath:currentRunner.fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (currentRunner.fileName != nil) {
        if ([manager fileExistsAtPath:fullPath]){
            self.addPhotoLabel.hidden = true;
            self.aiv.hidden = false;
            [self.aiv startAnimating];
        
            UIImage *originalImage = [[UIImage alloc] initWithContentsOfFile:fullPath];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                
                if ([currentRunner.photoOrientation isEqual: @"portrait"]) {
                    CGImageRef imageRef = [originalImage CGImage];
                    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        self.runnerImageView.image = rotatedImage;
                        [self.aiv stopAnimating];
                        self.aiv.hidden = true;
                    });
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^(void) {
                        self.runnerImageView.image = originalImage;
                        [self.aiv stopAnimating];
                        self.aiv.hidden = true;
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

- (IBAction)addPhotoButtonPressed:(id)sender {
    self.runnerImageView.image = nil;
    self.aiv.hidden = false;
    [self.aiv startAnimating];
    self.addPhotoLabel.hidden = true;
    self.delegate.currentRunner = self.runner;
    [self.delegate choosePicture];
}

@end
