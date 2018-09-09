//
//  Coaches.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/8/18.
//  Copyright © 2018 Adam Zarn. All rights reserved.
//

#import "Coaches.h"
#import "PersonView.h"
#import "CoachClass.h"
#import "AppDelegate.h"
#import "GlobalFunctions.h"
@import GoogleMobileAds;

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(...) {}
#endif

@interface Coaches ()

@property (weak, nonatomic) IBOutlet PersonView *coachView;

@end

@implementation Coaches {
    NSMutableArray *coaches;
    UIView *dimView;
    UITextField *firstResponder;
    NSIndexPath *indexPathBeingEdited;
    AppDelegate *appDelegate;
    UIBarButtonItem *addButton;
    NSString *uneditedName;
}

//UIViewController Life Cycle Methods*************************************************************************

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.persistentContainer.viewContext;
    
    self.coachView.title.textColor = appDelegate.darkBlue;
    self.coachView.delegate = self;
    [self.coachView.runnerGender removeFromSuperview];
    [self.coachView.runnerTeam removeFromSuperview];
    
    coaches = [[NSMutableArray alloc] init];
    
    [self getCoaches];
    [self.myTableView reloadData];
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                 target:self
                 action:@selector(addCoach:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:addButton, nil];
    
    dimView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.5f];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.coachView.hidden = YES;
    self.coachView.layer.cornerRadius = 5;
    self.coachView.userInteractionEnabled = NO;
    
    self.coachView.nameTextField.delegate = self;
    self.coachView.emailTextField.delegate = self;
    self.coachView.email2TextField.delegate = self;

    [self.coachView.saveButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    [self.coachView.cancelButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    
    self.coachView.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.coachView.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.coachView.email2TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
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
    return [coaches count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    CoachClass *currentCoach = [coaches objectAtIndex:indexPath.row];
    cell.textLabel.text = currentCoach.name;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Delete Coach?" message:@"Are you sure you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
            [self.context deleteObject:[coaches objectAtIndex:indexPath.row]];
            [appDelegate saveContext];
            
            [self getCoaches];
            [self.myTableView reloadData];
            
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

- (void)addCoach:(id)sender {
    
    self.coachView.title.text = @"New Coach";
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    self.coachView.userInteractionEnabled = YES;
    self.coachView.hidden = NO;
    [self.view bringSubviewToFront:self.coachView];
    [self.coachView.nameTextField becomeFirstResponder];
    
}

- (void)editCoach:(NSIndexPath *)indexPath {
    
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    
    self.coachView.userInteractionEnabled = YES;
    self.coachView.hidden = NO;
    [self.view bringSubviewToFront:self.coachView];
    
    self.coachView.title.text = @"Edit Coach";
    [self.coachView.nameTextField becomeFirstResponder];
    
    CoachClass *coachToEdit = [coaches objectAtIndex:indexPath.row];
    self.coachView.nameTextField.text = coachToEdit.name;
    uneditedName = coachToEdit.name;
    self.coachView.emailTextField.text = coachToEdit.email;
    self.coachView.email2TextField.text = coachToEdit.email2;
    
}

//PersonViewDelegate Methods**********************************************************************************

-(void)didPressSave {
    
    //Check to see if the coach already exists, only if adding a new coach.
    BOOL alreadyExists = NO;
    for (CoachClass *coach in coaches) {
        if ([self.coachView.nameTextField.text isEqual: coach.name] && ![uneditedName isEqual:coach.name]) {
            alreadyExists = YES;
            break;
        }
    }
    
    if (alreadyExists) {
        
        UIAlertController *alert=   [UIAlertController alertControllerWithTitle:@"Duplicate Entry." message:@"Coach names must be unique. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) { [alert dismissViewControllerAnimated:YES completion:nil]; }];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } else {
        
        if ([self.coachView.title.text isEqual: @"Edit Coach"]) { //if editing coach
            
            NSManagedObject *selectedCoach = [coaches objectAtIndex:indexPathBeingEdited.row];
            
            [selectedCoach setValue:self.coachView.nameTextField.text forKey:@"name"];
            [selectedCoach setValue:self.coachView.emailTextField.text forKey:@"email"];
            [selectedCoach setValue:self.coachView.email2TextField.text forKey:@"email2"];
            
            [appDelegate saveContext];
            
            [self getCoaches];
            [self.myTableView reloadData];
            
        } else { //if adding new coach
            
            NSManagedObject *savedCoach = [NSEntityDescription insertNewObjectForEntityForName:@"Coach" inManagedObjectContext:self.context];
            [savedCoach setValue:self.coachView.nameTextField.text forKey:@"name"];
            [savedCoach setValue:self.coachView.emailTextField.text forKey:@"email"];
            [savedCoach setValue:self.coachView.email2TextField.text forKey:@"email2"];
            
            [appDelegate saveContext];
            
            [self getCoaches];
            [self.myTableView reloadData];
            
        }
        
        [self dismissCoachView];
        
    }
    
}

-(void)didPressCancel {
    [self dismissCoachView];
}

//Helper Methods**********************************************************************************************

-(void)getCoaches {
    NSArray *results = [GlobalFunctions getData:@"Coach" context:self.context];
    coaches = [results mutableCopy];
}

- (void)dismissCoachView {
    self.coachView.hidden = YES;
    self.coachView.userInteractionEnabled = NO;
    [dimView removeFromSuperview];
    self.coachView.nameTextField.text = @"";
    self.coachView.emailTextField.text = @"";
    self.coachView.email2TextField.text = @"";
    [firstResponder resignFirstResponder];
}

@end
