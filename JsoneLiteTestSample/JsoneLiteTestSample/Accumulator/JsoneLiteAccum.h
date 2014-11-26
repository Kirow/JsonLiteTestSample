//
// Created by Feather4 on 11/10/14.
// Copyright (c) 2014 Appus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonLiteParser.h"

@class JsoneLiteAccum;

@protocol JsoneLiteAccumDelegate <NSObject>
- (void)processed:(NSUInteger)objects;

- (void)complete:(JsoneLiteAccum *)writer;
@end

@interface JsoneLiteAccum : NSObject <JsonLiteParserDelegate>
@property(weak, nonatomic) id <JsoneLiteAccumDelegate> delegate;

- (instancetype)initWithDelegate:(id <JsoneLiteAccumDelegate>)delegate;

+ (instancetype)writerWithDelegate:(id <JsoneLiteAccumDelegate>)delegate;

@end