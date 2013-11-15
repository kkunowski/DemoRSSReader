//
// Created by Krzysztof Kunowski on 09/11/13.
// Copyright (c) 2013 Future4Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlParseOperation : NSOperation <NSXMLParserDelegate>

- (id)initWithData:(NSData *)parseData;

@end