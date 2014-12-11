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
    NSArray *arrayURI;
}
@end

@implementation MainViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.searchBar.showsCancelButton = NO;
    self.arrayEvents = [NSMutableArray new];
    arrayURI = @[@"http://upload.wikimedia.org/wikipedia/commons/5/54/Google_Mountain_View_campus_dinosaur_skeleton_'Stan'.jpg",
                @"http://static4.businessinsider.com/image/534c28a2eab8ead94f263a7d/google-buys-drone-company-titan-aerospace.jpg",
                 @"http://media.npr.org/assets/img/2013/05/12/google_glass_next_wide-e40daf1be811bf34700fd0379b2c64e4f0bb11ea.jpg",
                 @"http://static6.businessinsider.com/image/52c6edd169beddbe1f39f0e6/see-what-google-glass-apps-will-actually-look-like.jpg",
                 @"http://media1.s-nbcnews.com/i/newscms/2014_08/202526/140221-google-glass-jhc-1730_01e477c41457035fca77e169019bb530.jpg",
                 @"http://cnet4.cbsistatic.com/hub/i/r/2013/05/01/1fefba01-67c3-11e3-a665-14feb5ca9861/thumbnail/770x433/927dd9d4acc1a88f05767fb4c3187e95/GoogleGlass_35339166_03.jpg"];
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
                                                  newArticle.articleImageURL = [arrayURI objectAtIndex:([self.arrayEvents count] % 6)]; //[NSString stringWithFormat:@"http://placehold.it/1700x1700&text=ArticleImage%lu", (unsigned long)[self.arrayEvents count]]; // @"http://static.adzerk.net/Advertisers/6a84d696ad6c4679804e4923a617ade4.png";
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
