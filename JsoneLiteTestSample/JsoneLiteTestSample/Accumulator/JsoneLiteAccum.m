//
// Created by Feather4 on 11/10/14.
// Copyright (c) 2014 Appus. All rights reserved.
//

#import "JsoneLiteAccum.h"

static void *array;
static void *object;

#define COUNT_BARRIER 2

@interface JsoneLiteAccum ()
@property(strong, nonatomic) NSMutableArray *stack;
@property(nonatomic) NSUInteger totalObjects;
@end

@implementation JsoneLiteAccum

- (void)setTotalObjects:(NSUInteger)totalObjects {
    _totalObjects = totalObjects;
    [self.delegate processed:_totalObjects];
}

- (id)init {
    self = [super init];
    if (self) {
        _totalObjects = 0;
        _stack = [NSMutableArray array];
    }

    return self;
}

- (instancetype)initWithDelegate:(id <JsoneLiteAccumDelegate>)delegate {
    self = [self init];
    if (self) {
        self.delegate = delegate;
    }

    return self;
}

+ (instancetype)writerWithDelegate:(id <JsoneLiteAccumDelegate>)delegate {
    return [[self alloc] initWithDelegate:delegate];
}


#pragma mark - JsonLiteParserDelegate

- (void)parserDidStartObject:(JsonLiteParser *)parser {
    [self.stack addObject:[NSValue valueWithPointer:object]];
}

- (void)parserDidEndObject:(JsonLiteParser *)parser {
    NSAssert([self.stack.lastObject pointerValue] == object, @"Stack was broken");
    [self.stack removeLastObject];
    if (self.stack.count == COUNT_BARRIER) {
        ++self.totalObjects;
    }
}

- (void)parserDidStartArray:(JsonLiteParser *)parser {
    [self.stack addObject:[NSValue valueWithPointer:array]];
}

- (void)parserDidEndArray:(JsonLiteParser *)parser {
    NSAssert([self.stack.lastObject pointerValue] == array, @"Stack was broken");
    [self.stack removeLastObject];
}

- (void)parser:(JsonLiteParser *)parser foundKeyToken:(JsonLiteStringToken *)token {

}

- (void)parser:(JsonLiteParser *)parser foundStringToken:(JsonLiteStringToken *)token {
    NSString *string = [token copyStringWithBytesNoCopy];

}

- (void)parser:(JsonLiteParser *)parser foundNumberToken:(JsonLiteNumberToken *)token {

}

- (void)parserFoundTrueToken:(JsonLiteParser *)parser {

}

- (void)parserFoundFalseToken:(JsonLiteParser *)parser {

}

- (void)parserFoundNullToken:(JsonLiteParser *)parser {

}

- (void)parser:(JsonLiteParser *)parser didFinishParsingWithError:(NSError *)error {
    if (error.code == 1) return; //end of stream
    TOCK;
    NSLog(@"Total Items parsed - %i", _totalObjects);
    [self.delegate complete:self];
}

@end