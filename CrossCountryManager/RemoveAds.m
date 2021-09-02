//
//  RemoveAds.m
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/30/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

#import "RemoveAds.h"
#import "AppDelegate.h"
#define removeAdsProductID @"AJZ.CrossCountryManager.RemoveAds"

@interface RemoveAds ()

@end

@implementation RemoveAds {
    AppDelegate *appDelegate;
    UITextField *firstResponder;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    purchaseButton.layer.borderWidth = 2;
    purchaseButton.layer.borderColor = appDelegate.darkBlue.CGColor;
    [purchaseButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    purchaseButton.layer.cornerRadius = 4;
    
    submitButton.layer.borderWidth = 2;
    submitButton.layer.borderColor = appDelegate.darkBlue.CGColor;
    [submitButton setTitleColor:appDelegate.darkBlue forState:UIControlStateNormal];
    submitButton.layer.cornerRadius = 4;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    [toolBar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(dismissNumberPad:)];
    toolBar.items = @[flex, barButtonDone];
    barButtonDone.tintColor = appDelegate.darkBlue;
    barButtonDone.style = UIBarButtonItemStyleDone;
    
    UIView *inputAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolBar.frame.size.height)];
    inputAccessoryView.backgroundColor = [UIColor clearColor];
    [inputAccessoryView addSubview:toolBar];
    
    couponCodeTextField.inputAccessoryView = inputAccessoryView;
    couponCodeTextField.delegate = self;
}

-(void)dismissNumberPad:(id)sender {
    [firstResponder resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
    firstResponder = textField;
}

- (void) viewWillAppear:(BOOL)animated {
    aiv.hidden = false;
    [aiv startAnimating];
    productDescription.hidden = true;
    purchaseButton.hidden = true;
    couponCodeLabel.hidden = true;
    couponCodeTextField.hidden = true;
    submitButton.hidden = true;
    
    purchasingAiv.hidden = true;
    purchasingLabel.hidden = true;
    
    [self fetchAvailableProducts];
    
}

-(void)fetchAvailableProducts{
    NSSet *productIdentifiers = [NSSet
                                 setWithObjects:removeAdsProductID,nil];
    productsRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog([error debugDescription]);
}

- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}
- (void)purchaseMyProduct:(SKProduct*)product{
    if ([self canMakePurchases]) {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else {
        UIAlertController *alert = [[UIAlertController alloc] init];
        alert.title = @"Purchases are disabled on your device";
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
-(IBAction)purchase:(id)sender {
    [purchasingAiv startAnimating];
    purchasingAiv.hidden = false;
    purchasingLabel.hidden = false;
    [self purchaseMyProduct:[validProducts objectAtIndex:0]];
    purchaseButton.enabled = false;
}

-(void)paymentQueue:(SKPaymentQueue *)queue
updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
            case SKPaymentTransactionStatePurchased:
                if ([transaction.payment.productIdentifier
                     isEqualToString:removeAdsProductID]) {
                    NSLog(@"Purchased");
                    [self setUpPurchasedView];
                    [purchasingAiv stopAnimating];
                    purchasingAiv.hidden = true;
                    purchasingLabel.hidden = true;
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"paid"];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored");
                [self setUpPurchasedView];
                [purchasingAiv stopAnimating];
                purchasingAiv.hidden = true;
                purchasingLabel.hidden = true;
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"paid"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed");
                [purchasingAiv stopAnimating];
                purchasingAiv.hidden = true;
                purchasingLabel.hidden = true;
                break;
            default:
                break;
        }
    }
}

- (void) setUpPurchasedView {
    [purchaseButton setTitle:@"  Purchased  " forState:UIControlStateNormal];
    [productDescription setText:@"Ads have been removed."];
    purchaseButton.enabled = false;
    couponCodeLabel.hidden = true;
    couponCodeTextField.hidden = true;
    couponCodeTextField.enabled = false;
    submitButton.hidden = true;
    submitButton.enabled = false;
}

-(void)productsRequest:(SKProductsRequest *)request
    didReceiveResponse:(SKProductsResponse *)response
{
    NSUInteger count = [response.products count];
    if (count>0) {
        validProducts = response.products;
    }
    aiv.hidden = true;
    [aiv stopAnimating];
    productDescription.hidden = false;
    purchaseButton.hidden = false;
    couponCodeLabel.hidden = false;
    couponCodeTextField.hidden = false;
    submitButton.hidden = false;
}

- (IBAction)submitButtonPressed:(id)sender {
    
    [firstResponder resignFirstResponder];
    
    NSString *title = [[NSString alloc] init];
    NSString *message = [[NSString alloc] init];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                    message:@""
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    if ([couponCodeTextField.text isEqualToString:@"4815162342"]) {
        NSLog(@"Here");
        title = @"Code Accepted";
        message = @"Ads have been removed.";
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"paid"];
                                 [self->firstResponder resignFirstResponder];
                                 [self.navigationController popViewControllerAnimated:true];
                             }];
        [alert addAction:ok];
    } else {
        title = @"Invalid code.";
        message = @"Please try again.";
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:nil];
        [alert addAction:ok];
    }
    
    alert.title = title;
    alert.message = message;
    
    [self presentViewController:alert animated:true completion:nil];
    
}


@end
