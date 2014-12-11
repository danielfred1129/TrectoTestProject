//
//  LoginVC.m
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import "LoginVC.h"
#import "LROAuth2Client.h"
#import "OAuthCredentials.h"
#import "LROAuth2AccessToken.h"
#import "OAuthRequestController.h"
#import "ASIHTTPRequest.h"
#import "NSString+QueryString.h"
#import "NSObject+YAJL.h"
#import "MainViewVC.h"

NSString * AccessTokenSavePath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"OAuthAccessToken.cache"];
}

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccessToken:) name:OAuthReceivedAccessTokenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRefreshAccessToken:) name:OAuthRefreshedAccessTokenNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    // try and load an existing access token from disk
    self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithFile:AccessTokenSavePath()];
    
    // check if we have a valid access token before continuing otherwise obtain a token
    if (self.accessToken != nil) {
        [self pushMainView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    [self beginAuthorization];
}

- (void)didReceiveAccessToken:(NSNotification *)note;
{
    self.accessToken = (LROAuth2AccessToken *)note.object;
    NSLog(@"accessToken:%@", self.accessToken);
    
    [self saveAccessTokenToDisk];
    [self pushMainView];
}

- (void)didRefreshAccessToken:(NSNotification *)note;
{
    self.accessToken = (LROAuth2AccessToken *)note.object;
    
    [self saveAccessTokenToDisk];
    [self pushMainView];
}

#pragma mark -

- (void)saveAccessTokenToDisk;
{
    [NSKeyedArchiver archiveRootObject:self.accessToken toFile:AccessTokenSavePath()];
}

- (void)beginAuthorization;
{
    OAuthRequestController *oauthController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OAuthRequestController"];
    [self presentViewController:oauthController animated:YES completion:^{
        
    }];
}

- (void)pushMainView
{
    MainViewVC *mainViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainViewVC"];
    [self.navigationController pushViewController:mainViewController animated:YES];
}


@end
