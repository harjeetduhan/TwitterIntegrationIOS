//
//  ViewController.m
//  TwitterIntegration
//
//  Created by bliss on 26/05/17.
//  Copyright © 2017 bliss. All rights reserved.
//

#import "ViewController.h"

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface ViewController ()

@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;
@property (nonatomic, strong) NSString *usernameusername;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.accountStore = [[ACAccountStore alloc] init];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

///******************  LOGIN WITH APP----------------------------------*******************
- (IBAction)loginWithApp:(id)sender
{
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        __weak typeof(self) weakSelf = self;
        NSString *status = nil;
        if(account)
        {
            status = [NSString stringWithFormat:@"Did select %@", account.username];
            [weakSelf loginWithiOSAccount:account];
        } else
        {
            status = errorMessage;
        }
        
       // weakSelf.loginStatusLabel.text = status;
    };
    
    [self chooseAccount];

}

- (void)loginWithiOSAccount:(ACAccount *)account
{
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID)
     {
         //_loginStatusLabel.text = [NSString stringWithFormat:@"@%@ (%@)", username, userID];
         NSLog(@"User Name--- %@   UserId---- %@",username,userID);
         
         
         //Get User Information
         [_twitter getUserInformationFor:username successBlock:^(NSDictionary *user)
         {
              NSLog(@"User Dictionary- -- %@ ", user);
             NSString *name =[user valueForKey:@"name"];
                        NSLog(@"User Name- -- %@ ", name);
             self.lblname.text=name;

         } errorBlock:^(NSError *error)
         {
             NSLog(@"Failes with erroe--%@",[error localizedDescription]);

         }];
         
         //End Get User Information
         
         
         
         //GETTIMELINE
         [_twitter getUserTimelineWithScreenName:username successBlock:^(NSArray *statuses)
         {
                NSLog(@"Statuses -- %@ ", statuses);
             NSLog(@"Statuses  Count  -- %lu ", (unsigned long)[statuses count]);

         } errorBlock:^(NSError *error)
          {
              NSLog(@"Failes with erroe--%@",[error localizedDescription]);
         }];
        //  End GETTIMELINE
         
     } errorBlock:^(NSError *error)
    {
            NSLog(@"Failes with erroe--%@",[error localizedDescription]);
    }];
    
}
//Chosse Accounts
- (void)chooseAccount
{
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO)
            {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 1)
            {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [as showInView:self.view.window];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif
    
}
///****************** END LOGIN WITH APP----------------------------------*******************


///******************  LOGIN WITH WEB----------------------------------*******************

- (IBAction)loginWithWeb:(id)sender
{
   _twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"zISxSgkIdO58W0nYPn8dVbsE6"
                                                 consumerSecret:@"lJm3TDnTxd64tQXehQWxj4Jggnk5BY3VtKiwm9VUJfBZSinqa2"];
    
    //_loginStatusLabel.text = @"Trying to login with Safari...";
   // _loginStatusLabel.text = @"";
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken)
     {
         [[UIApplication sharedApplication] openURL:url];

        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
//        if([self.openSafariSwitch isOn])
//        {
//            [[UIApplication sharedApplication] openURL:url];
//        } else
//        {
//            WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
//            
//            [self presentViewController:webViewVC animated:YES completion:^{
//                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                [webViewVC.webView loadRequest:request];
//            }];
//        }
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://twitter_access_tokens/"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                       // _loginStatusLabel.text = [error localizedDescription];
                    }];

}


- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName)
    {
        NSLog(@"-- screenName: %@", screenName);
        
      //  _loginStatusLabel.text = [NSString stringWithFormat:@"%@ (%@)", screenName, userID];
       // _usernameusername=screenName;
        
        
        
        
    } errorBlock:^(NSError *error)
    {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}



///******************END  LOGIN WITH WEB----------------------------------*******************
@end
