//
//  OAuthRequestController.m
//  LROAuth2Demo
//
//  Created by Luke Redpath on 01/06/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "OAuthRequestController.h"
#import "LROAuth2Client.h"
#import "OAuthCredentials.h"

NSString *const OAuthReceivedAccessTokenNotification  = @"OAuthReceivedAccessTokenNotification";
NSString *const OAuthRefreshedAccessTokenNotification = @"OAuthRefreshedAccessTokenNotification";

@implementation OAuthRequestController

@synthesize webView;

- (void)viewDidLoad
{
    self.webView.delegate = self;
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Logging in...";
    [HUD show:YES];

    oauthClient = [[LROAuth2Client alloc] initWithClientID:kOAuthClientID
                                                    secret:kOAuthClientSecret redirectURL:[NSURL URLWithString:kOAuthClientAuthURL]];
    oauthClient.debug = YES;
    oauthClient.delegate = self;
    oauthClient.userURL  = [NSURL URLWithString:@"https://secure.meetup.com/oauth2/authorize"];
    oauthClient.tokenURL = [NSURL URLWithString:@"https://secure.meetup.com/oauth2/access"];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.webView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [HUD hide:YES];
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"touch" forKey:@"display"];
    [oauthClient authorizeUsingWebView:self.webView additionalParameters:params];
}

- (void)dealloc
{
  oauthClient.delegate = nil;
  webView.delegate = nil;
}

- (void)refreshAccessToken:(LROAuth2AccessToken *)accessToken
{
  [oauthClient refreshAccessToken:accessToken];
}

#pragma mark -
#pragma mark LROAuth2ClientDelegate methods

- (void)oauthClientDidReceiveAccessToken:(LROAuth2Client *)client
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:OAuthReceivedAccessTokenNotification object:client.accessToken];
    }];
}

- (void)oauthClientDidRefreshAccessToken:(LROAuth2Client *)client
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:OAuthRefreshedAccessTokenNotification object:client.accessToken];
    }];
}

#pragma mark - UIWebViewDelegate - 
- (void)webViewDidFinishLoad:(UIWebView *)webView_ {
    if ([[webView_ stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
    }
}
@end
