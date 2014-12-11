//
//  OAuthRequestController.h
//  LROAuth2Demo
//
//  Created by Luke Redpath on 01/06/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LROAuth2ClientDelegate.h"
#import "MBProgressHUD.h"

@class LROAuth2Client;
@class LROAuth2AccessToken;

extern NSString *const OAuthReceivedAccessTokenNotification;
extern NSString *const OAuthRefreshedAccessTokenNotification;

@interface OAuthRequestController : UIViewController <LROAuth2ClientDelegate, MBProgressHUDDelegate, UIWebViewDelegate> {
    LROAuth2Client *oauthClient;
    UIWebView *webView;
    MBProgressHUD *HUD;
}
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)refreshAccessToken:(LROAuth2AccessToken *)accessToken;
@end
