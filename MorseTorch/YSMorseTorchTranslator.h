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

- (void) didTransmitMorseCharacter:(NSString *) character;

@end

@interface YSMorseTorchTranslator : NSObject

@property (unsafe_unretained) id <YSMorseTorchTranslatorDelegate> delegate;
@property int unit;

+(YSMorseTorchTranslator *) sharedTranslator;

- (void) transmitMorseCharacter:(NSString *) character;

@end
