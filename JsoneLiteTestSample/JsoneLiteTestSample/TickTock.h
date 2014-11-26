//
// Created by Kirow on 09.11.14.
// Copyright (c) 2014 Appus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TICK   [TickTock tick]
#define TOCK   [TickTock tock]

@interface TickTock : NSObject

+ (void)tick;

+ (void)tock;

@end