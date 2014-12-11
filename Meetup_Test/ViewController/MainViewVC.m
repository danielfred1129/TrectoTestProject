//
//  MainViewVC.m
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import "MainViewVC.h"
#import "ArticleDetailVC.h"
#import "ArticleTableViewCell.h"
#import "AFFNetworking.h"
#import "MBProgressHUD.h"
#import "Article.h"

#define API_BASE_URL @"http://api.meetup.com/topics"
#define API_KEY @"81c1a5d355635345b203150853255a"

@interface MainViewVC ()
{
    MBProgressHUD *HUD;
}
@end

@implementation MainViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.searchBar.showsCancelButton = NO;
    self.arrayEvents = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadEvent
{
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = @"Loading events...";
    [HUD show:YES];

    NSString *reqString = [NSString stringWithFormat:@"%@?key=%@&search=%@&only=id,name", API_BASE_URL, API_KEY, self.searchBar.text];
    NSString *encoded_url = [reqString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Load Event URL: %@", encoded_url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encoded_url]];
    AFFJSONRequestOperation *operation = [AFFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                          {
                                              NSLog(@"Loaded Events : %@", JSON);
                                              [HUD hide:YES];
                                              
                                              NSDictionary *result = (NSDictionary *)JSON;
                                              NSArray *articleArray = [result objectForKey:@"results"];
                                              NSLog(@"Result:%@", articleArray);
                                              
                                              [self.arrayEvents removeAllObjects];
                                              
                                              for (NSDictionary *article in articleArray) {
                                                  Article *newArticle = [Article new];
                                                  newArticle.articleId = [article objectForKey:@"id"];
                                                  newArticle.articleContent = [article objectForKey:@"name"];
                                                  newArticle.articleImageURL = @"http://static.adzerk.net/Advertisers/6a84d696ad6c4679804e4923a617ade4.png";
                                                  [self.arrayEvents addObject:newArticle];
                                              }
                                              [self.tableView reloadData];
                                          } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                          {
                                              [HUD hide:YES];
                                              [self.arrayEvents removeAllObjects];
                                              [self.tableView reloadData];
                                          }];
    [operation start];
}

#pragma mark UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Cancel clicked");
    [searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Clicked");
    [searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
    [self loadEvent];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayEvents count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArticleTableViewCell";
    ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ArticleTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Article *article = [self.arrayEvents objectAtIndex:indexPath.row];
    [cell.lblTitle setText:article.articleId];
    [cell.lblDescription setText:article.articleContent];
    [cell setImageURL:[NSURL URLWithString:article.articleImageURL]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;

    ArticleDetailVC *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ArticleDetailVC"];
    Article *article = [self.arrayEvents objectAtIndex:indexPath.row];
    viewController.article = article;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
