//
//  RemoveAds.h
//  CrossCountryManager
//
//  Created by Adam Zarn on 9/30/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface RemoveAds : UIViewController<UITextFieldDelegate,
SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    SKProductsRequest *productsRequest;
    NSArray *validProducts;
    IBOutlet UILabel *productDescription;
    IBOutlet UIButton *purchaseButton;
    __weak IBOutlet UILabel *couponCodeLabel;
    __weak IBOutlet UIActivityIndicatorView *aiv;
    __weak IBOutlet UIButton *submitButton;
    __weak IBOutlet UITextField *couponCodeTextField;
    
    __weak IBOutlet UIActivityIndicatorView *purchasingAiv;
    __weak IBOutlet UILabel *purchasingLabel;
    
}
- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
- (IBAction)purchase:(id)sender;

@end
