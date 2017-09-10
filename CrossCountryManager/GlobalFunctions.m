//
//  GlobalFunctions.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/28/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "GlobalFunctions.h"
#import "ResultClass.h"
#import "AppDelegate.h"
#import "RunnerClass.h"

@implementation GlobalFunctions

+ (NSArray *) getData:(NSString *)entity context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];

    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
    
}

+ (NSArray *) getData:(NSString *)entity pred:(NSString *)pred context:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:pred]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
}

+ (NSArray *) getData:(NSString *)entity pred:(NSString *)pred predArray:(NSArray *)predArray context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:pred argumentArray:predArray]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];

    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return results;
}

+ (RunnerClass *) getCurrentRunner:(NSString *)entity pred:(NSString *)pred name:(NSString *)name context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:pred, name]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    NSLog(@"%@", results);
    
    if (!results) {
        NSLog(@"Error fetching objects: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    return [results objectAtIndex:0];
}

+ (NSString *)getAverageMileTime:(NSArray *)results {
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    double totalMiles = 0.0;
    double totalSeconds = 0.0;
    
    if ([results count] == 0) {
        return @"0:00";
    }
    
    for (ResultClass *result in results) {
        totalMiles = totalMiles + [result.distance doubleValue];
        
        NSRange secondsRange = NSMakeRange(3, 2);
        NSRange minutesRange = NSMakeRange(0, 2);
        
        NSString *seconds = [result.time substringWithRange:secondsRange];
        NSString *minutes = [result.time substringWithRange:minutesRange];
        
        NSNumber *s = [f numberFromString:seconds];
        NSNumber *m = [f numberFromString:minutes];
        
        totalSeconds = totalSeconds + [s floatValue] + [m floatValue]*60.0;
    }
    
    double secondsPerMile = totalSeconds/totalMiles;
    
    int min = floor(secondsPerMile/60);
    int sec = floor(secondsPerMile);
    
    if (sec >= 60) {
        sec = sec % 60;
    }
    
    NSString *averageMileTime = [[NSString alloc] init];
    
    if (min > 9) {
        averageMileTime = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    } else {
        averageMileTime = [NSString stringWithFormat:@"%01d:%02d",min,sec];
    }
    
    return averageMileTime;
    
}

+ (UIView *)configureTwoLineTitleView:(NSString *)topLine bottomLine:(NSString *)bottomLine {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -4, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = appDelegate.darkBlue;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.text = topLine;
    [titleLabel sizeToFit];

    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = appDelegate.darkBlue;
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    subTitleLabel.text = bottomLine;
    [subTitleLabel sizeToFit];

    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabel];
    [twoLineTitleView addSubview:subTitleLabel];

    float widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width;

    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2;
        titleLabel.frame = CGRectIntegral(frame);
    } else {
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = fabsf(widthDiff) / 2;
        subTitleLabel.frame = CGRectIntegral(frame);
    }
    
    return twoLineTitleView;
    
}

+ (NSArray *)sortWithKey:(NSString *)key {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return sortDescriptors;
}

+ (NSString *) getFullPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}



@end
