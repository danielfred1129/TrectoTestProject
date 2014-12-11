//
//  LoginVC.h
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@class LROAuth2AccessToken;

@interface LoginVC : UIViewController <ASIHTTPRequestDelegate>
{
    NSArray *friends;
    NSMutableData *_data;
}

@property (nonatomic, retain) LROAuth2AccessToken *accessToken;

- (IBAction)onLogin:(id)sender;
- (void)saveAccessTokenToDisk;
- (void)beginAuthorization;

@end
