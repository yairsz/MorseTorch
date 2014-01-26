//
//  NSString+MorseCode.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "NSString+MorseCode.h"

@implementation NSString (MorseCode)

- (NSArray *) morseCodeArray
{//returns array of morse code symbols for each character
    NSString * stringLowCaps = [self lowercaseString];
    NSMutableArray * morseSymbolsArray = [NSMutableArray new];
    for (int i = 0; i < stringLowCaps.length; i++) {
        NSString * character = [stringLowCaps substringWithRange:NSMakeRange(i, 1)];
        NSString * morseSymbol = [self moresCodeFromCharacter:character];
        [morseSymbolsArray addObject:morseSymbol];
    }
    return [NSArray arrayWithArray:morseSymbolsArray];

}

- (NSString *) moresCodeFromCharacter:(NSString *) character //returns morse for one character
{
    NSString * firstChar = [character substringWithRange:NSMakeRange(0, 1)];
    NSDictionary * morseDict = [self morseDictionary];
    return morseDict[firstChar] ? morseDict[firstChar] : @"?";
}

- (NSString *) alphanumericFromMorseString: (NSString *) morseString{
    
    return nil;
    
}

- (NSDictionary *) morseDictionary
{
    return @{
             @"a" : @".-",
             @"b" : @"-...",
             @"c" : @"-.-.",
             @"d" : @"-..",
             @"e" : @".",
             @"f" : @"..-.",
             @"g" : @"--.",
             @"h" : @"....",
             @"i" : @"..",
             @"j" : @".---",
             @"k" : @"-.-",
             @"l" : @".-..",
             @"m" : @"--",
             @"n" : @"-.",
             @"o" : @"---",
             @"p" : @".--.",
             @"q" : @"--.-",
             @"r" : @".-.",
             @"s" : @"...",
             @"t" : @"-",
             @"u" : @"..-",
             @"v" : @"...-",
             @"w" : @".--",
             @"x" : @"-..-",
             @"y" : @"-.--",
             @"z" : @"--..",
             @"1" : @".----",
             @"2" : @"..---",
             @"3" : @"...--",
             @"4" : @"....-",
             @"5" : @".....",
             @"6" : @"-....",
             @"7" : @"--...",
             @"8" : @"---..",
             @"9" : @"----.",
             @"0" : @"-----",
             @" " : @" "
             };
}

- (NSDictionary *) morseToAlphaDictionary
{
    return @{
             @".-" :@"a",
             @"-..." :@"b",
             @"-.-." :@"c",
             @"-.." :@"d",
             @"." :@"e",
             @"..-." :@"f",
             @"--." :@"g",
             @"...." :@"h",
             @".." :@"i",
             @".---" :@"j",
             @"-.-" :@"k",
             @".-.." :@"l",
             @"--" :@"m",
             @"-." :@"n",
             @"---" :@"o",
             @".--." :@"p",
             @"--.-" :@"q",
             @".-." :@"r",
             @"..." :@"s",
             @"-" :@"t",
             @"..-" :@"u",
             @"...-" :@"v",
             @".--" :@"w",
             @"-..-" :@"x",
             @"-.--" :@"y",
             @"--.." :@"z",
             @".----" :@"1",
             @"..---" :@"2",
             @"...--" :@"3",
             @"....-" :@"4",
             @"....." :@"5",
             @"-...." :@"6",
             @"--..." :@"7",
             @"---.." :@"8",
             @"----." :@"9",
             @"-----" :@"0",
             @"  ":@" "

             };
}

@end
