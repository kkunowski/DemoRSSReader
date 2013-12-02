//
// Created by Krzysztof Kunowski on 09/11/13.
// Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import "XmlParseOperation.h"
#import "RssFeed.h"

@implementation XmlParseOperation {
    NSMutableString *_parseXmlElementValue;
    RssFeed *_parseRssFeed;
    NSData *_parseData;
    NSMutableArray *_resultRssFeeds;
}

- (id)initWithData:(NSData *)parseData {
    self = [super init];
    if (self) {
        _parseData = parseData;
        _parseXmlElementValue = [NSMutableString new];
    }
    return self;
}

// call when xml parse finished
- (void)addRssFeeds:(NSMutableArray *)rssFeeds {
    NSLog(@"test %@",[rssFeeds objectAtIndex:0]);
    // assert([NSThread isMainThread]);
   // [[NSNotificationCenter defaultCenter] postNotificationName:kAddRssFeedsNotificationName object:rssFeeds];
}

// call when parser error occurred
- (void)handleError:(NSError *)parseError {
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kErrorNotificationName object:parseError];
}

- (void)main {
    if (!self.isCancelled) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:_parseData];
        [parser setDelegate:self];
        [parser parse];
    }
}

#pragma mark - NSXMLParse const

static NSString *const kRssElementName = @"rss";
static NSString *const kItemElementName = @"item";
static NSString *const kTitleElementName = @"title";
static NSString *const kAuthorElementName = @"trackArtist";
static NSString *const kLinkElementName = @"link";

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:kRssElementName]) {
        _resultRssFeeds = [NSMutableArray array];
    } else if ([elementName isEqualToString:kItemElementName]) {
        _parseRssFeed = [RssFeed new];
    }
    [_parseXmlElementValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:kRssElementName]) {
        if (!self.isCancelled) {
            [self performSelectorOnMainThread:@selector(addRssFeeds:) withObject:_resultRssFeeds waitUntilDone:NO];
        }
    } else if ([elementName isEqualToString:kItemElementName]) {
        [_resultRssFeeds addObject:_parseRssFeed];
    }
    else if ([elementName isEqualToString:kTitleElementName]) {
        _parseRssFeed.title = [_parseXmlElementValue copy];
    }
    else if ([elementName isEqualToString:kLinkElementName]) {
        _parseRssFeed.link = [_parseXmlElementValue copy];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_parseXmlElementValue appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError) {
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

@end