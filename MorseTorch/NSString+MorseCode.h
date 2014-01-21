//
//  NSString+MorseCode.h
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MorseCode)


- (NSArray *) morseCodeArray; //returns array of morse code symbols for each character
- (NSString *) moresCodeFromCharacter:(NSString *) character; //returns morse for one character

@end
