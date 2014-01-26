//
//  YSMorseTorchTranslator.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/22/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseTorchTranslator.h"
#import "YSTorchController.h"
#import "NSString+MorseCode.h"

#define INITIAL_UNIT 100000
#define CALIBRATION_STRING @"s a a  "

@interface YSMorseTorchTranslator ()

@property (weak, nonatomic) YSTorchController * sharedTorch;
@property (strong, nonatomic) NSOperationQueue * morseCodeQueue;

@end

@implementation YSMorseTorchTranslator

#pragma mark - Initialization

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

- (NSOperationQueue *) morseCodeQueue
{
    if (!_morseCodeQueue) {
        _morseCodeQueue = [NSOperationQueue new];
        [_morseCodeQueue setMaxConcurrentOperationCount:1];
    }
    return _morseCodeQueue;
}

#pragma mark - Calibration

- (void) transmitCalibration {
    
    NSOperationQueue * mainQueue = [NSOperationQueue mainQueue];
    [self.morseCodeQueue addOperationWithBlock:^{
        NSOperation * currentOperation = [[self.morseCodeQueue operations] lastObject];
        NSString  * calibrationString = CALIBRATION_STRING;
        NSArray * morseArray = [calibrationString morseCodeArray];
        [mainQueue addOperationWithBlock:^{
            [self.delegate willTransmitCalibration];
        }];
        for (int i = 0; i < morseArray.count; i++) {
            
            if (!currentOperation.isCancelled){
                NSString * character = morseArray[i];
                [self transmitMorseCharacter:character];
            }
        }
        if (!currentOperation.isCancelled){
            [mainQueue addOperationWithBlock:^{
                [self.delegate didTransmitCalibration];
            }];
        }
    }];
    
}

#pragma mark - Transmit Message

- (void) transmitMorseArray: (NSArray *) morseArray
{
    NSOperationQueue * mainQueue = [NSOperationQueue mainQueue];
    [self.morseCodeQueue addOperationWithBlock:^{
        NSOperation * currentOperation = [[self.morseCodeQueue operations] lastObject];
        for (int i = 0; i < morseArray.count; i++) {
            
            if (!currentOperation.isCancelled){
                NSString * character = morseArray[i];
                
                [mainQueue addOperationWithBlock:^{
                    [self.delegate willTransmitCharacterAtIndex:i];
                }];
                [self transmitMorseCharacter:character];
                if (!currentOperation.isCancelled){
                    [mainQueue addOperationWithBlock:^{
                        [self.delegate didTransmitCharacterAtIndex:i];
                    }];
                }
            }
        }
        if (!currentOperation.isCancelled){
            [mainQueue addOperationWithBlock:^{
                [self.delegate didFinishTransmitingMorseArray];
            }];
        }
        
    }];
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

            [self partSpace];
    }
    [self characterSpace];
}

- (void) cancelTransmission
{
    [self.morseCodeQueue cancelAllOperations];
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
    usleep(self.unit);
    //     NSLog(@"partspace");
}

- (void) characterSpace
{
    usleep(self.unit * 3);
    //     NSLog(@"character space");
}





@end
