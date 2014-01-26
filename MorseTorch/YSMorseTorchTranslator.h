//
//  YSMorseTorchTranslator.h
//  MorseTorch
//
//  Created by Yair Szarf on 1/22/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSMorseTorchTranslatorDelegate <NSObject>

@optional

- (void) didTransmitCharacterAtIndex:(NSInteger) i;
- (void) willTransmitCharacterAtIndex:(NSInteger) i;
- (void) didFinishTransmitingMorseArray;
- (void) willTransmitCalibration;
- (void) didTransmitCalibration;

@end

@interface YSMorseTorchTranslator : NSObject

@property (unsafe_unretained) id <YSMorseTorchTranslatorDelegate> delegate;
@property int unit;

+(YSMorseTorchTranslator *) sharedTranslator;

- (void) transmitMorseArray: (NSArray *) morseArray;
- (void) cancelTransmission;
- (void) transmitCalibration;

@end
