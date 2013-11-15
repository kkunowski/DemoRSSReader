//
//  DemoRSSReaderTests.m
//  DemoRSSReaderTests
//
//  Created by Krzysztof Kunowski on 09/11/13.
//  Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LSNocilla.h"
#import "MasterViewController.h"
#import "RssFeedTableViewCell.h"
#import "OCMock.h"
#import "OCObserverMockObject.h"
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface MasterViewController ()

@property (nonatomic, readonly) NSMutableArray *rssFeeds;

-(void)handleError:(NSError *)error;
-(void)openLinkForRssFeed:(RssFeed *)rssFeed;

@end

@interface DemoRSSReaderTests : XCTestCase

@end

@implementation DemoRSSReaderTests

- (void)setUp {
    [super setUp];
    [[LSNocilla sharedInstance] start];
}

- (void)tearDown {
    [super tearDown];
    [[LSNocilla sharedInstance] clearStubs];
    [[LSNocilla sharedInstance] stop];
}

-(void)stubSampleRequest {
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *testBundlePath = [testBundle pathForResource:@"SampleResponse" ofType:@"xml"];
    NSError *error;
    NSString *responseBody = [NSString stringWithContentsOfFile:testBundlePath encoding:NSUTF8StringEncoding error:&error];
    stubRequest(@"GET", kDemoApiUrl).andReturn(200).withHeaders(@{@"Content-Type" : @"application/xml"}).withBody(responseBody);
}

- (void)testHandleRSSFeedResponse {
    [self stubSampleRequest];
    MasterViewController *masterViewController = [[MasterViewController alloc] init];
    [masterViewController view];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    RssFeed *rssFeed1 = [masterViewController.rssFeeds objectAtIndex:0];
    RssFeed *rssFeed2 = [masterViewController.rssFeeds objectAtIndex:1];
    RssFeed *rssFeed3 = [masterViewController.rssFeeds objectAtIndex:2];
    [masterViewController reloadRssFeeds];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [masterViewController reloadRssFeeds];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    assertThatInt([masterViewController.tableView numberOfRowsInSection:0], equalToInt(3));
    assertThatInt([masterViewController.rssFeeds count], equalToInt(3));
    assertThat(rssFeed1.title,is(@"title1"));
    assertThat(rssFeed1.link,is(@"http://link1.com"));
    assertThat(rssFeed2.title,is(@"title2"));
    assertThat(rssFeed2.link,is(@"http://link2.com"));
    assertThat(rssFeed3.title,is(@"title3"));
    assertThat(rssFeed3.link,is(@"http://link3.com"));
}

- (void)testHandleRSSFeedResponseError {
    stubRequest(@"GET", kDemoApiUrl).andReturn(404);
    MasterViewController *masterViewController = [MasterViewController alloc];
    NSError *error = [NSError errorWithDomain:@"HTTP"
                                         code:404
                                     userInfo:nil];
    id masterViewControllerMock = [OCMockObject partialMockForObject:masterViewController];
    [[masterViewControllerMock expect] handleError:error];
    [masterViewController init];
    [masterViewController view];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    [masterViewControllerMock verify];
}

- (void)testOpenRSSFeedLink {
    [self stubSampleRequest];
    MasterViewController *masterViewController = [MasterViewController alloc];
    RssFeed *rssFeed = [[RssFeed alloc] init];
    id masterViewControllerMock = [OCMockObject partialMockForObject:masterViewController];
    [masterViewController init];
    [masterViewController view];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    RssFeed *rssFeed1 = [masterViewController.rssFeeds objectAtIndex:0];
    [[masterViewControllerMock expect] openLinkForRssFeed:rssFeed1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [masterViewController tableView:masterViewController.tableView didSelectRowAtIndexPath:indexPath];

    [masterViewControllerMock verify];
}

- (void)testRssTableViewCell {
    RssFeed *rssFeed = [[RssFeed alloc] init];
    rssFeed.title = @"title1";
    RssFeedTableViewCell *rssFeedTableViewCell = [[RssFeedTableViewCell alloc] init];
    rssFeedTableViewCell.artistLabel = [UILabel new];
    rssFeedTableViewCell.titleLabel = [UILabel new];
    [rssFeedTableViewCell configWithRssFeed:rssFeed];

    assertThat(rssFeedTableViewCell.titleLabel.text, is(@"title1"));
}

@end
