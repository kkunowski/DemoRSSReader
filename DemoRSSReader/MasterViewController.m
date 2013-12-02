//
//  MasterViewController.m
//  DemoRSSReader
//
//  Created by Krzysztof Kunowski on 09/11/13.
//  Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import "MasterViewController.h"
#import "XmlParseOperation.h"
#import "RssFeed.h"
#import "RssFeedTableViewCell.h"

@interface MasterViewController () {
    NSOperationQueue *_operationsQueue;
    NSMutableArray *_rssFeeds;
}

@property (nonatomic, readonly) NSMutableArray *rssFeeds;

@end

@implementation MasterViewController

@synthesize rssFeeds = _rssFeeds;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _operationsQueue = [NSOperationQueue new];
    _rssFeeds = [NSMutableArray array];
    [self addObservers];
    [self reloadRssFeeds];
}

-(IBAction)reloadRssFeeds {
    if([_rssFeeds count] > 0) {
        [_rssFeeds removeAllObjects];
        [self.tableView reloadData];
    }
    if([_operationsQueue operationCount] > 0) {
        [_operationsQueue cancelAllOperations];
    }
    NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:kDemoApiUrl]];
    [NSURLConnection sendAsynchronousRequest:requestUrl
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   [self handleError:error];
                               }
                               else {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                   if ([httpResponse statusCode] == 200) {
                                       XmlParseOperation *parseOperation = [[XmlParseOperation alloc] initWithData:data];
                                       [_operationsQueue addOperation:parseOperation];
                                   } else {
                                       NSError *responseError = [NSError errorWithDomain:@"HTTP"
                                                                                    code:[httpResponse statusCode]
                                                                                userInfo:nil];
                                       [self handleError:responseError];
                                   }
                               }
                           }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rssFeeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RssFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    RssFeed *rssFeed = _rssFeeds[indexPath.row];
    [cell configWithRssFeed:rssFeed];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
       return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RssFeed *rssFeed = _rssFeeds[indexPath.row];
    [self openLinkForRssFeed:rssFeed];
}

-(void)openLinkForRssFeed:(RssFeed *)rssFeed {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: rssFeed.link]];
}

-(void)handleAddRssFeedsNotification:(NSNotification *)notification {
        _rssFeeds  = (NSMutableArray *)[notification object];
        [self.tableView reloadData];
}

-(void)handleError:(NSError *)error {
     UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [errorAlertView show];
}

#pragma - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleError:)
                                                 name:kErrorNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleAddRssFeedsNotification:)
                                                 name:kAddRssFeedsNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kErrorNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAddRssFeedsNotificationName
                                                  object:nil];
}

@end