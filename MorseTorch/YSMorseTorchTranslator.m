//
//  YSMorseTorchTranslator.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/22/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseTorchTranslator.h"
#import "YSTorchController.h"

#define INITIAL_UNIT 100000

@interface YSMorseTorchTranslator ()

@property (weak, nonatomic) YSTorchController * sharedTorch;

@end

@implementation YSMorseTorchTranslator

+(YSMorseTorchTranslator *) sharedTranslator{
    static dispatch_once_t pred;
    static YSMorseTorchTranslator *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[YSMorseTorchTranslator alloc] init];
    });
    shared.unit = INITIAL_UNIT;
    shared.sharedTorch = [YSTorchController sharedTorch];
    return shared;
}



- (void)transmitMorseCharacter:(NSString *)character
{
    for (int j = 0; j < character.length; j++) {
        NSString * morseCharacter = [character substringWithRange:NSMakeRange(j, 1)];
        if ([morseCharacter isEqualToString:@"."]) {
            //                            NSLog(@"dot if");
            [self dot];
            
        } else if ([morseCharacter isEqualToString:@"-"]) {
            //                            NSLog(@"dash if");
            [self dash];
        } else if ([morseCharacter isEqualToString:@" "]) {
            //                            NSLog(@"space if");
            [self wordSpace];
            continue;
        }
        if (j < character.length -1) {
            //                            NSLog(@"partspace if");
            [self partSpace];
        }
        
    }
    [self.delegate didTransmitMorseCharacter:character];
    [self characterSpace];
}

#pragma mark - Morse Code
- (void) dot
{
    [self.sharedTorch torchOn];
    usleep(self.unit);
    [self.sharedTorch torchOff];
    //    NSLog(@"dot");
}

- (void) dash
{
    [self.sharedTorch torchOn];
    usleep(self.unit*3);
    [self.sharedTorch torchOff];
    //     NSLog(@"dash");
}

- (void) wordSpace
{
    usleep(self.unit * 7);
    //    NSLog(@"wordspace");
}

-(void) partSpace {
    usleep(self.unit*2);
    //     NSLog(@"partspace");
}

- (void) characterSpace
{
    usleep(self.unit * 3);
    //     NSLog(@"character space");
}




@end
