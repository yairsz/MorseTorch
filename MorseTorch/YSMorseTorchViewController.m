//
//  YSViewController.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseTorchViewController.h"
#import "YSTorchController.h"
#import "YSAppDelegate.h"
#import <ProgressHUD.h>

#define INITIAL_UNIT 100000

@interface YSMorseTorchViewController ()
{
    NSOperationQueue * morseCodeQueue;
    int lastMorseEOL;
}
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *morseTextView;
@property (weak, nonatomic) IBOutlet UITextView *originalTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *morseLabel;
@property (weak, nonatomic) IBOutlet UILabel *characterLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;


@property (nonatomic) NSArray * morseCodeArray;
@property (weak, nonatomic) YSTorchController * sharedTorch;
@property (strong, nonatomic) NSString * stringToMorsify;
@property int unit;


@end

@implementation YSMorseTorchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    YSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    self.sharedTorch = appDelegate.sharedTorch;
    self.unit = INITIAL_UNIT;
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    self.stringToMorsify = textField.text;
    self.morseCodeArray = [self.stringToMorsify morseCodeArray];
    NSMutableString * morseString = [NSMutableString new], *originalString = [NSMutableString new];
    
    for (int i = 0; i < self.morseCodeArray.count; i++){
        [morseString appendFormat:@"      %@\n",self.morseCodeArray[i]];
        [originalString appendFormat:@"      %@\n",[self.stringToMorsify substringWithRange:NSMakeRange(i,1)]];
        
    }

    self.morseTextView.text = morseString;
    self.originalTextView.text = originalString;
    
    self.morseTextView.textAlignment = NSTextAlignmentRight;
    self.morseTextView.textAlignment = NSTextAlignmentLeft;
    

    
}


#pragma mark - IB Actions
- (IBAction)speedSliderChanged:(UISlider *)sender {
    self.unit = sender.value;
}


- (IBAction)startButtonPressed:(UIButton *)sender {
    lastMorseEOL = 0;
    [self startMorseTorchSequence];
}

- (IBAction)stopButtonPressed:(UIButton *)sender {
    [morseCodeQueue cancelAllOperations];
}

-(void) startMorseTorchSequence
{
    morseCodeQueue = [NSOperationQueue new];
    [morseCodeQueue setMaxConcurrentOperationCount:1];
    __weak YSMorseTorchViewController * weakSelf = self;
    [morseCodeQueue addOperationWithBlock:^{
        NSOperationQueue * mainQueue = [NSOperationQueue mainQueue];
        NSOperation * currentOperation = [[morseCodeQueue operations] lastObject];
        
            for (int i = 0; i < weakSelf.morseCodeArray.count; i++) {
                if (!currentOperation.isCancelled){
                    NSString * character = weakSelf.morseCodeArray[i];
                    [mainQueue addOperationWithBlock:^{
                        [weakSelf updateCharacterWithIndex:i];
                    }];
                    for (int j = 0; j < character.length; j++) {
                        NSString * morseCharacter = [character substringWithRange:NSMakeRange(j, 1)];
                        if ([morseCharacter isEqualToString:@"."]) {
//                            NSLog(@"dot if");
                            [weakSelf dot];
                            
                        } else if ([morseCharacter isEqualToString:@"-"]) {
//                            NSLog(@"dash if");
                            [weakSelf dash];
                        } else if ([morseCharacter isEqualToString:@" "]) {
//                            NSLog(@"space if");
                            [weakSelf characterSpace];
                            continue;
                        }
                        if (j < character.length -1) {
//                            NSLog(@"partspace if");
                            [weakSelf partSpace];
                        }
                    }
                [weakSelf wordSpace];
                }
            }
        [mainQueue addOperationWithBlock:^{
            [ProgressHUD showSuccess:@"Success!"];
        }];
    }];
}

-(void) stopMorseSequence
{
    [morseCodeQueue cancelAllOperations];
    
}

- (void) updateCharacterWithIndex:(int) i {
    self.characterLabel.text = [self.stringToMorsify substringWithRange:NSMakeRange(i,1)];
    self.morseLabel.text = [self.morseCodeArray objectAtIndex:i];
    
    NSMutableAttributedString *attrMorseText = [self.morseTextView.attributedText mutableCopy];
    [attrMorseText setAttributes:nil range:NSMakeRange(0,attrMorseText.length)];
    NSMutableAttributedString *attrOriginalText = [self.originalTextView.attributedText mutableCopy];
    [attrOriginalText setAttributes:nil range:NSMakeRange(0, attrOriginalText.length)];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: [UIColor whiteColor]];
    [shadow setShadowOffset:CGSizeMake (3.0, 3.0)];
    [shadow setShadowBlurRadius:1];
    
    int morseCharacterLength = (int) self.morseLabel.text.length;
    
    
    [attrMorseText setAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor]}
                           range:NSMakeRange(lastMorseEOL,morseCharacterLength + 7)];
    [attrOriginalText setAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor]}
                              range:NSMakeRange(i*8,8)];
    lastMorseEOL = lastMorseEOL + morseCharacterLength + 7;
    
    self.morseTextView.attributedText = attrMorseText;
    self.originalTextView.attributedText = attrOriginalText;
    
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

-(void) partSpace {
    usleep(self.unit*2);
//     NSLog(@"partspace");
}

- (void) characterSpace
{
    usleep(self.unit * 3);
//     NSLog(@"character space");
}

- (void) wordSpace
{
    usleep(self.unit * 7);
//    NSLog(@"wordspace");
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //This is a gist by @johnnyclem https://gist.github.com/johnnyclem/8215415 well done!
    for (UIControl *control in self.view.subviews) {
        if ([control isKindOfClass:[UITextField class]]) {
            [control endEditing:YES];
        }
    }
}

#pragma mark - UITextViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.morseTextView) {
        self.originalTextView.contentOffset = scrollView.contentOffset;
    } else if (scrollView == self.originalTextView){
        self.morseTextView.contentOffset = scrollView.contentOffset;
        
    }
    
}




@end
