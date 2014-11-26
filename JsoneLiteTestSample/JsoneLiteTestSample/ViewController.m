//
//  ViewController.m
//  JsoneLiteTestSample
//
//  Created by Kirow on 24.11.14.
//  Copyright (c) 2014 Home. All rights reserved.
//

#import <mach/mach.h>
#import "ViewController.h"
#import "JsonLiteParser.h"

#define FILE_SIZE 189778220
#define OBJECT_COUNT 206560
#define FILE_PATH [[NSBundle mainBundle] pathForResource:@"citylots" ofType:@"json"]

NSString *report_memory(void) {
    static unsigned last_resident_size = 0;
    static unsigned greatest = 0;

    NSString *result = nil;

    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
            TASK_BASIC_INFO,
            (task_info_t) &info,
            &size);
    if (kerr == KERN_SUCCESS) {
        int diff = (int) info.resident_size - (int) last_resident_size;
        unsigned latest = info.resident_size;
        if (latest > greatest) greatest = latest;  // track greatest mem usage
        NSNumberFormatter *formatter = [NSNumberFormatter new];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        formatter.groupingSize = 3;
        formatter.groupingSeparator = @" ";
        result = [NSString stringWithFormat:@"%@KB", [formatter stringFromNumber:@(info.resident_size / 1024)]];
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    last_resident_size = info.resident_size;

    return result;
}

@interface ViewController () <NSStreamDelegate, JsonLiteParserDelegate>
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;
@property(weak, nonatomic) IBOutlet UILabel *memoryLabel;
@property(weak, nonatomic) IBOutlet UILabel *progressLabel;

@property(weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _progressLabel.text = @"0";
    _statusLabel.text = @"Idle";
    _memoryLabel.text = @"Undef";

}

- (IBAction)startProcessing:(UIButton *)sender {
    NSLog(@"startProcessing");
    _memoryLabel.text = report_memory();
    _progressLabel.text = @"0";
    _statusLabel.text = @"Idle";

    TICK;
    dispatch_async(dispatch_queue_create("com.parser.queue", DISPATCH_QUEUE_SERIAL), ^{
        @autoreleasepool {
            NSFileHandle *readFile = [NSFileHandle fileHandleForReadingAtPath:FILE_PATH];
            if (readFile) {
                // Get the total file length
                [readFile seekToEndOfFile];
                unsigned long long fileLength = [readFile offsetInFile];
                // Set file offset to start of file
                unsigned long long currentOffset = 0ULL;

                JsonLiteParser *parser = [JsonLiteParser parserWithDepth:32];
                parser.delegate = self;

                // Read the data and append it to the file
                while (currentOffset < fileLength) {
                    @autoreleasepool {
                        [readFile seekToFileOffset:currentOffset];
                        NSData *chunkOfData = [readFile readDataOfLength:1024 * 1024]; //leak depends of chunk size
                        [parser parse:chunkOfData];
                        currentOffset += chunkOfData.length;
                    }
                }

                // Release the file handle
                [readFile closeFile];
            }
        }
    });

    sender.enabled = NO;
    _statusLabel.text = @"Processing...";

}

//- (void)processed:(NSUInteger)objects {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        float progress = (float) objects / OBJECT_COUNT;
//        [self.progressView setProgress:progress animated:YES];
//        _progressLabel.text = [NSString stringWithFormat:@"%.2f%%",progress*100];
//    });
//}

#pragma mark - JsonLiteParserDelegate

- (void)parserDidStartObject:(JsonLiteParser *)parser {

}

- (void)parserDidEndObject:(JsonLiteParser *)parser {

}

- (void)parserDidStartArray:(JsonLiteParser *)parser {

}

- (void)parserDidEndArray:(JsonLiteParser *)parser {

}

- (void)parser:(JsonLiteParser *)parser foundKeyToken:(JsonLiteStringToken *)token {

}

- (void)parser:(JsonLiteParser *)parser foundStringToken:(JsonLiteStringToken *)token {

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
    if (error.code == 1) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        _statusLabel.text = @"Idle";
        _startButton.enabled = YES;
        _memoryLabel.text = report_memory();
        TOCK;
    });
}


@end