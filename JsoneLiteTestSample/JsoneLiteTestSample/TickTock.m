//
// Created by Kirow on 09.11.14.
// Copyright (c) 2014 Appus. All rights reserved.
//


@implementation TickTock {
    NSDate *_date;
}

+ (TickTock *)instance {
    static TickTock *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
        }
    }

    return _instance;
}

+ (void)tick {
    self.instance->_date = [NSDate date];
}

+ (void)tock {
    NSLog(@"Time: %f", -[self.instance->_date timeIntervalSinceNow]);
}


@end