//
//  RssFeedTableViewCell.m
//  DemoRSSReader
//
//  Created by Krzysztof Kunowski on 10/11/13.
//  Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import "RssFeedTableViewCell.h"

@implementation RssFeedTableViewCell

@synthesize iconImageView, artistLabel, titleLabel;

- (void)configWithRssFeed:(RssFeed *)rssFeed {
    self.titleLabel.text = rssFeed.title;
}

@end
