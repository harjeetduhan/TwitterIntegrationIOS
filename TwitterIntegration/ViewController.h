//
//  ViewController.h
//  TwitterIntegration
//
//  Created by bliss on 26/05/17.
//  Copyright © 2017 bliss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Social/SLRequest.h>

@interface ViewController : UIViewController<STTwitterAPIOSProtocol>

- (IBAction)loginWithApp:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *lblname;
- (IBAction)loginWithWeb:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;



@end

