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

+ (RunnerClass *) getCurrentRunner:(NSString *)name context:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Runner"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
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
    
    if (min > 59) {
        averageMileTime = [NSString stringWithFormat:@"%02d:%02d",59,59];
    } else if (min > 9) {
        averageMileTime = [NSString stringWithFormat:@"%02d:%02d",min,sec];
    } else {
        averageMileTime = [NSString stringWithFormat:@"%01d:%02d",min,sec];
    }
    
    return averageMileTime;
    
}

+ (double)getSecondsPerMile:(NSString *)averageMileTime {
    
    if ([averageMileTime isEqualToString:@"0:00"]) {
        return 10000;
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    NSUInteger l = [averageMileTime length];
    NSRange secondsRange = NSMakeRange(l-2,2);
    NSRange minutesRange = NSMakeRange(0,l-3);
        
    NSString *seconds = [averageMileTime substringWithRange:secondsRange];
    NSString *minutes = [averageMileTime substringWithRange:minutesRange];
        
    NSNumber *s = [f numberFromString:seconds];
    NSNumber *m = [f numberFromString:minutes];
        
    return [s floatValue] + [m floatValue]*60.0;

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

+ (NSString *) getLapString:(NSString *)lap1 lap2:(NSString *)lap2 lap3:(NSString *)lap3 {
    NSMutableArray *laps = [[NSMutableArray alloc] init];
    
    if (!([lap1 length] == 0)) {
        [laps addObject: [NSString stringWithFormat:@"Lap 1: %@",lap1]];
    }
    if (!([lap2 length] == 0)) {
        [laps addObject: [NSString stringWithFormat:@"Lap 2: %@",lap2]];
    }
    if (!([lap3 length] == 0)) {
        [laps addObject: [NSString stringWithFormat:@"Lap 3: %@",lap3]];
    }
    
    if ([laps count] == 0) {
        return @"No Lap Data";
    } else {
        return [laps componentsJoinedByString:@", "];
    }
    
}

+ (NSString *) getGroup:(NSInteger)g t:(NSInteger)t {
    
    NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)g,(long)t];
    NSDictionary *titleLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"All Runners",@"00",
                                 @"Varsity",@"01",
                                 @"Junior Varsity",@"02",
                                 @"Boys",@"10",
                                 @"Varsity - Boys",@"11",
                                 @"Junior Varsity - Boys",@"12",
                                 @"Girls",@"20",
                                 @"Varsity - Girls",@"21",
                                 @"Junior Varsity - Girls",@"22", nil];
    
    return [titleLookup objectForKey:key];
    
}

+ (NSString *) getPredicate:(NSInteger)g t:(NSInteger)t {
    
    NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)g,(long)t];
    
    NSDictionary *predicateLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"gender == 'Boy' OR gender == 'Girl'",@"00",
                                     @"team == 'Varsity'",@"01",
                                     @"team == 'Junior Varsity'",@"02",
                                     @"gender == 'Boy'",@"10",
                                     @"gender == 'Boy' AND team == 'Varsity'",@"11",
                                     @"gender == 'Boy' AND team == 'Junior Varsity'",@"12",
                                     @"gender == 'Girl'",@"20",
                                     @"gender == 'Girl' AND team == 'Varsity'",@"21",
                                     @"gender == 'Girl' AND team == 'Junior Varsity'",@"22", nil];
    
    return [predicateLookup objectForKey:key];
    
}

+ (NSString *) getPredicate:(NSString *)indices {
    
    NSDictionary *predicateLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"gender == 'Boy' OR gender == 'Girl'",@"00",
                                     @"team == 'Varsity'",@"01",
                                     @"team == 'Junior Varsity'",@"02",
                                     @"gender == 'Boy'",@"10",
                                     @"gender == 'Boy' AND team == 'Varsity'",@"11",
                                     @"gender == 'Boy' AND team == 'Junior Varsity'",@"12",
                                     @"gender == 'Girl'",@"20",
                                     @"gender == 'Girl' AND team == 'Varsity'",@"21",
                                     @"gender == 'Girl' AND team == 'Junior Varsity'",@"22", nil];
    
    return [predicateLookup objectForKey:indices];
    
}

+ (NSString *) getIndicesFromGroup:(NSString *)group {
    
    NSDictionary *titleLookup = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"00",@"All Runners",
                                 @"01",@"Varsity",
                                 @"02",@"Junior Varsity",
                                 @"10",@"Boys",
                                 @"11",@"Varsity - Boys",
                                 @"12",@"Junior Varsity - Boys",
                                 @"20",@"Girls",
                                 @"21",@"Varsity - Girls",
                                 @"22",@"Junior Varsity - Girls", nil];
    
    return [titleLookup objectForKey:group];
    
}



@end
