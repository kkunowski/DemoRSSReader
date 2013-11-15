//
//  RssFeedTableViewCell.h
//  DemoRSSReader
//
//  Created by Krzysztof Kunowski on 10/11/13.
//  Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssFeed.h"

@interface RssFeedTableViewCell : UITableViewCell

@property(nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic) IBOutlet UIImageView *iconImageView;
@property(nonatomic) IBOutlet UILabel *artistLabel;

- (void)configWithRssFeed:(RssFeed *)rssFeed;

@end
