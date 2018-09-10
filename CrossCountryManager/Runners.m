//
//  Runners.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 10/17/16.
//  Copyright © 2016 Adam Zarn. All rights reserved.
//

#import "Runners.h"
#import "PersonView.h"
#import "RunnerClass.h"
#import "RunnerCell.h"
#import "AppDelegate.h"
#import "RacesOfRunner.h"
#import "GlobalFunctions.h"
#import "RemoveAds.h"
@import GoogleMobileAds;

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@interface Runners ()

@property (weak, nonatomic) IBOutlet PersonView *runnerView;

@end

@implementation Runners {
    NSMutableArray *allRunners;
    NSMutableArray *selectedRunners;
    UIView *dimView;
    UITextField *firstResponder;
    NSIndexPath *indexPathBeingEdited;
    NSInteger allRunnersRow;
    AppDelegate *appDelegate;
    UIBarButtonItem *addButton;
    NSString *uneditedName;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.persistentContainer.viewContext;
    
    self.runnerView.title.textColor = appDelegate.darkBlue;
    self.runnerView.delegate = self;
    
    allRunners = [[NSMutableArray alloc] init];
    selectedRunners = [[NSMutableArray alloc] init];
    
    [self getRunners];
    [self updateTableView];

    selectedRunners = [[selectedRunners sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"name"]] mutableCopy];
    
    addButton = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                             target:self
                                             action:@selector(addRunner:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton, nil];
    
    dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.5f];
    [self.genderSegment setTitle:@"All" forSegmentAtIndex:0];
    [self.genderSegment setTitle:@"Boys" forSegmentAtIndex:1];
    [self.genderSegment setTitle:@"Girls" forSegmentAtIndex:2];
    [self.teamSegment setTitle:@"All" forSegmentAtIndex:0];
    [self.teamSegment setTitle:@"Varsity" forSegmentAtIndex:1];
    [self.teamSegment setTitle:@"Junior Varsity" forSegmentAtIndex:2];
    
    self.genderSegment.tintColor = appDelegate.darkBlue;
    self.teamSegment.tintColor = appDelegate.darkBlue;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.runnerView.hidden = YES;
    self.runnerView.layer.cornerRadius = 5;
    self.runnerView.userInteractionEnabled = NO;
    
    self.runnerView.nameTextField.delegate = self;
    self.runnerView.emailTextField.delegate = self;
    self.runnerView.email2TextField.delegate = self;
    
    [self.runnerView.runnerGender setTitle:@"Boy" forSegmentAtIndex:0];
    [self.runnerView.runnerGender setTitle:@"Girl" forSegmentAtIndex:1];
    [self.runnerView.runnerTeam setTitle:@"Varsity" forSegmentAtIndex:0];
    [self.runnerView.runnerTeam setTitle:@"Junior Varsity" forSegmentAtIndex:1];
    
    self.runnerView.runnerGender.tintColor = appDelegate.darkBlue;
    self.runnerView.runnerTeam.tintColor = appDelegate.darkBlue;
    [self.runnerView.saveButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    [self.runnerView.cancelButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    
    self.runnerView.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.runnerView.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.runnerView.email2TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:appDelegate.darkBlue}];
    [self.navigationController.navigationBar setTintColor:appDelegate.darkBlue];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tabBarController.tabBar setTintColor:appDelegate.darkBlue];

}

- (void) viewWillAppear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"paid"]) {
        
        self.bannerView = [[GADBannerView alloc]
                           initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.bannerView.delegate = self;
        
        self.bannerView.adUnitID = @"ca-app-pub-4590926477342036/1366258771";
        self.bannerView.rootViewController = self;
        
        GADRequest *request = [GADRequest request];
        [self.bannerView loadRequest:request];
        
    } else {
        self.myTableView.tableHeaderView = nil;
    }
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    self.myTableView.tableHeaderView.frame = bannerView.frame;
    self.myTableView.tableHeaderView = bannerView;
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
}


//UITableViewDelegate Methods*********************************************************************************

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [selectedRunners count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RunnerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SimpleTableItem"];
    cell.delegate = self;
    
    RunnerClass *currentRunner = [selectedRunners objectAtIndex:indexPath.row];
    cell.runner = currentRunner;
    
    [cell setUpCell:currentRunner];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    indexPathBeingEdited = indexPath;
    [self editRunner:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RacesOfRunner *vc = [self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"RacesOfRunner"];
    
    RunnerClass *selectedRunner = [selectedRunners objectAtIndex:indexPath.row];
    vc.predArray = [NSArray arrayWithObjects: selectedRunner, nil];
    
    vc.name = [selectedRunner valueForKey:@"name"];
    vc.selectedRunner = selectedRunner;
    
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:false];
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Runner?" message:@"Are you sure you want to continue? This will delete all of this runner's individual race data." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
            RunnerClass *runnerToDelete = [self->selectedRunners objectAtIndex:indexPath.row];
            
            NSString *fullPath = [GlobalFunctions getFullPath:runnerToDelete.fileName];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:fullPath error:nil];
            
            [self.context deleteObject:[self->selectedRunners objectAtIndex:indexPath.row]];
            
            [self->appDelegate saveContext];
            
            [self getRunners];
            [self updateTableView];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:yes];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

//UITextFieldDelegate Methods*********************************************************************************

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
    firstResponder = textField;
}

//IBActions***************************************************************************************************

- (void)addRunner:(id)sender {
    
    self.runnerView.title.text = @"New Runner";
    if (self.genderSegment.selectedSegmentIndex > 0) {
        self.runnerView.runnerGender.selectedSegmentIndex = self.genderSegment.selectedSegmentIndex - 1;
        self.runnerView.runnerGender.enabled = NO;
    }
    if (self.teamSegment.selectedSegmentIndex > 0) {
        self.runnerView.runnerTeam.selectedSegmentIndex = self.teamSegment.selectedSegmentIndex - 1;
        self.runnerView.runnerTeam.enabled = NO;
    }
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    self.runnerView.userInteractionEnabled = YES;
    self.runnerView.hidden = NO;
    [self.view bringSubviewToFront:self.runnerView];
    [self.runnerView.nameTextField becomeFirstResponder];
    
}

- (void)editRunner:(NSIndexPath *)indexPath {
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.runnerView.userInteractionEnabled = YES;
    self.runnerView.hidden = NO;
    [self.view bringSubviewToFront:self.runnerView];
    
    self.runnerView.title.text = @"Edit Runner";
    [self.runnerView.nameTextField becomeFirstResponder];
    
    RunnerClass *runnerToEdit = [selectedRunners objectAtIndex:indexPath.row];
    self.runnerView.nameTextField.text = runnerToEdit.name;
    uneditedName = runnerToEdit.name;
    self.runnerView.emailTextField.text = runnerToEdit.email;
    self.runnerView.email2TextField.text = runnerToEdit.email2;
    if ([runnerToEdit.gender  isEqual: @"Boy"]) {
        self.runnerView.runnerGender.selectedSegmentIndex = 0;
    } else {
        self.runnerView.runnerGender.selectedSegmentIndex = 1;
    }
    if ([runnerToEdit.team  isEqual: @"Varsity"]) {
        self.runnerView.runnerTeam.selectedSegmentIndex = 0;
    } else {
        self.runnerView.runnerTeam.selectedSegmentIndex = 1;
    }
    
}
- (IBAction)genderFilterChanged:(id)sender {
    [self updateTableView];
}

- (IBAction)teamFilterChanged:(id)sender {
    [self updateTableView];
}

//PersonViewDelegate Methods**********************************************************************************

-(void)didPressSave {
    
    //Check to see if the runner already exists, only if adding a new runner.
    BOOL alreadyExists = NO;
    for (RunnerClass *runner in allRunners) {
        if ([self.runnerView.nameTextField.text isEqual: runner.name] && ![uneditedName isEqual:runner.name]) {
            alreadyExists = YES;
            break;
        }
    }
    
    if (alreadyExists) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Duplicate Entry." message:@"Runner names must be unique. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        if ([self.runnerView.title.text isEqual: @"Edit Runner"]) { //if editing runner
            
            NSManagedObject *selectedRunner = [selectedRunners objectAtIndex:indexPathBeingEdited.row];
            
            NSArray *results = [GlobalFunctions getData:@"Result" pred:@"resultToRunner = %@" predArray:[NSArray arrayWithObjects:selectedRunner,nil] context:self.context];
            
            for (NSManagedObject *result in results) {
                [result setValue:self.runnerView.nameTextField.text forKey:@"name"];
            }
            
            NSString *previousFileName = [NSString stringWithFormat:@"%@.jpeg",[selectedRunner valueForKey:@"name"]];
            NSString *newFileName = [NSString stringWithFormat:@"%@.jpeg",self.runnerView.nameTextField.text];
            [selectedRunner setValue:newFileName forKey:@"fileName"];
            
            NSString *previousFullPath = [GlobalFunctions getFullPath:previousFileName];
            NSString *newFullPath = [GlobalFunctions getFullPath:newFileName];
            
            NSFileManager *manager = [NSFileManager defaultManager];
            [manager moveItemAtPath:previousFullPath toPath:newFullPath error:nil];
            
            if (self.runnerView.runnerGender.selectedSegmentIndex == 0) {
                [selectedRunner setValue:@"Boy"forKey:@"gender"]; } else { [selectedRunner setValue:@"Girl"forKey:@"gender"]; }
            
            if (self.runnerView.runnerTeam.selectedSegmentIndex == 0) {
                [selectedRunner setValue:@"Varsity"forKey:@"team"]; } else { [selectedRunner setValue:@"Junior Varsity"forKey:@"team"]; }
            
            [selectedRunner setValue:self.runnerView.nameTextField.text forKey:@"name"];
            [selectedRunner setValue:self.runnerView.emailTextField.text forKey:@"email"];
            [selectedRunner setValue:self.runnerView.email2TextField.text forKey:@"email2"];
            
            [appDelegate saveContext];
            
            [self getRunners];
            [self updateTableView];
            
        } else { //if adding new runner
            
            NSManagedObject *savedRunner = [NSEntityDescription insertNewObjectForEntityForName:@"Runner" inManagedObjectContext:self.context];
            [savedRunner setValue:self.runnerView.nameTextField.text forKey:@"name"];
            [savedRunner setValue:[self.runnerView.runnerTeam titleForSegmentAtIndex:self.runnerView.runnerTeam.selectedSegmentIndex] forKey:@"team"];
            [savedRunner setValue:[self.runnerView.runnerGender titleForSegmentAtIndex:self.runnerView.runnerGender.selectedSegmentIndex] forKey:@"gender"];
            [savedRunner setValue:self.runnerView.emailTextField.text forKey:@"email"];
            [savedRunner setValue:self.runnerView.email2TextField.text forKey:@"email2"];
            [savedRunner setValue: [NSString stringWithFormat:@"%@.jpeg",self.runnerView.nameTextField.text] forKey:@"fileName"];
            
            [appDelegate saveContext];
            
            [self getRunners];
            [self updateTableView];
            
        }
        
        [self dismissRunnerView];
        
        self.runnerView.runnerGender.enabled = YES;
        self.runnerView.runnerTeam.enabled = YES;
        
    }
    
}

-(void)didPressCancel {
    [self dismissRunnerView];
}

//Helper Methods**********************************************************************************************

-(void)getRunners {
    NSArray *results = [GlobalFunctions getData:@"Runner" context:self.context];
    allRunners = [results mutableCopy];
    
    BOOL printedSectionals = NO;
    for (RunnerClass*runner in allRunners) {
        NSLog(@" ");
        NSLog(@"%@", runner.name);
        NSLog(@" ");
        NSArray *predArray = [NSArray arrayWithObjects:runner, nil];
        NSArray *results = [[GlobalFunctions getData:@"Result" pred:@"resultToRunner = %@" predArray:predArray context:self.context] mutableCopy];
        for (ResultClass *result in results) {
            if ([result.dateString isEqualToString:@"10/12/2017"]) {
                NSLog(@"10/7/2017 - Sectionals - ");
                printedSectionals = YES;
            }
            NSLog(@"%@ - %@ - %@ (%@ per mile)", result.dateString, result.meet, result.time, result.pace);
        }
        if (!printedSectionals) {
            NSLog(@"10/7/2017 - Sectionals - ");
        }
        printedSectionals = NO;
    }
    
}

-(void)updateTableView { //filter and sort runners, then reload tableView
    selectedRunners = [self filterArray:self.genderSegment.selectedSegmentIndex team:self.teamSegment.selectedSegmentIndex];
    selectedRunners = [[selectedRunners sortedArrayUsingDescriptors:[GlobalFunctions sortWithKey:@"name"]] mutableCopy];
    [self.myTableView reloadData];
}

- (NSMutableArray *)filterArray:(NSInteger)g team:(NSInteger)t {
    NSString *key = [NSString stringWithFormat:@"%ld%ld",(long)g,(long)t];
    NSDictionary *lookup = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"gender == 'Boy' OR gender == 'Girl'",@"00",
                          @"team == 'Varsity'",@"01",
                          @"team == 'Junior Varsity'",@"02",
                          @"gender == 'Boy'",@"10",
                          @"gender == 'Boy' AND team == 'Varsity'",@"11",
                          @"gender == 'Boy' AND team == 'Junior Varsity'",@"12",
                          @"gender == 'Girl'",@"20",
                          @"gender == 'Girl' AND team == 'Varsity'",@"21",
                          @"gender == 'Girl' AND team == 'Junior Varsity'",@"22", nil];
    
    NSString *value = [lookup objectForKey:key];
    NSPredicate *filter = [NSPredicate predicateWithFormat:value];
    NSArray *filteredArray = [allRunners filteredArrayUsingPredicate:filter];
    return [filteredArray mutableCopy];
}

-(void)choosePicture {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)dismissRunnerView {
    self.runnerView.hidden = YES;
    self.runnerView.userInteractionEnabled = NO;
    [dimView removeFromSuperview];
    self.runnerView.nameTextField.text = @"";
    [self.runnerView.runnerGender setSelectedSegmentIndex:0];
    [self.runnerView.runnerTeam setSelectedSegmentIndex:0];
    self.runnerView.emailTextField.text = @"";
    self.runnerView.email2TextField.text = @"";
    [firstResponder resignFirstResponder];

}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//UIImagePickerControllerDelegate Methods*********************************************************************

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = [self imageWithImage:image scaledToSize:CGSizeMake(120.0, 120.0)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage,1.0);
    
    NSInteger row = [selectedRunners indexOfObject:self.currentRunner];
    NSManagedObject *currentRunner = [selectedRunners objectAtIndex:row];
    RunnerClass *runner = self.currentRunner;
    
    NSString *fullPath = [GlobalFunctions getFullPath:runner.fileName];
    
    NSLog(@"pre writing to file");
    if (![imageData writeToFile:fullPath atomically:NO]) {
        NSLog(@"Failed to cache image data to disk");
    } else {
        NSLog(@"the cachedImagedPath is %@",fullPath);
    }
    
    [currentRunner setValue:runner.fileName forKey:@"fileName"];
    
    if (image.size.width > image.size.height) {
        [currentRunner setValue:@"landscape" forKey:@"photoOrientation"];
        runner.photoOrientation = @"landscape";
    } else {
        [currentRunner setValue:@"portrait" forKey:@"photoOrientation"];
        runner.photoOrientation = @"portrait";
    }
    
    [appDelegate saveContext];
    
    [self getRunners];
    [self updateTableView];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
    [self getRunners];
    [self updateTableView];
}

@end
