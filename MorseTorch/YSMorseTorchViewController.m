//
//  YSViewController.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseTorchViewController.h"
#import "YSAppDelegate.h"
#import <ProgressHUD.h>




@interface YSMorseTorchViewController ()
{
    int lastMorseEOL;
}
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *morseTextView;
@property (weak, nonatomic) IBOutlet UITextView *originalTextView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *morseLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalCharacterLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;


@property (nonatomic) NSArray * morseCodeArray;
@property (strong, nonatomic) NSString * stringToMorsify;
@property (strong, nonatomic) YSMorseTorchTranslator * torchTranslator;
@property BOOL willCalibrate;



@end

@implementation YSMorseTorchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.inputTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.torchTranslator = [YSMorseTorchTranslator sharedTranslator];
    self.torchTranslator.delegate = self;
    
    self.willCalibrate = NO;
    
    self.stringToMorsify = @"This is a morse Message";
    [self translateToMorseArrayAndSetTextFieldsWithString:self.stringToMorsify];
    
}

#pragma mark - IB Actions
- (IBAction)speedSliderChanged:(UISlider *)sender {
    self.torchTranslator.unit = sender.value;
}


- (IBAction)startButtonPressed:(UIButton *)sender {
    lastMorseEOL = 0;
    [self.inputTextField endEditing:YES];
    if (self.willCalibrate) [self.torchTranslator transmitCalibration];
    [self.torchTranslator transmitMorseArray:self.morseCodeArray];
    self.startButton.enabled = NO;
    self.startButton.backgroundColor = [UIColor grayColor];
    self.stopButton.enabled = YES;
    self.stopButton.backgroundColor = [UIColor redColor];
    
}

- (IBAction)stopButtonPressed:(UIButton *)sender {
    [self.torchTranslator cancelTransmission];
    self.startButton.backgroundColor = [UIColor greenColor];
    self.startButton.enabled = YES;
    self.stopButton.backgroundColor = [UIColor grayColor];
    self.stopButton.enabled = NO;
}


#pragma mark - YSMorseTorchTranslatorDelegate

- (void) didTransmitCharacterAtIndex:(NSInteger)i {
    [ProgressHUD showSuccess:[self.stringToMorsify substringWithRange:NSMakeRange(i,1)]];
}

- (void) willTransmitCharacterAtIndex:(NSInteger) i {
    
    // This method updates the UI right before each carachter is transmitted
    
    self.originalCharacterLabel.text = [self.stringToMorsify substringWithRange:NSMakeRange(i,1)];
    self.morseLabel.text = [self.morseCodeArray objectAtIndex:i];
    
    NSMutableAttributedString *attrMorseText = [self.morseTextView.attributedText mutableCopy];
    [attrMorseText setAttributes:nil range:NSMakeRange(0,attrMorseText.length)];
    NSMutableAttributedString *attrOriginalText = [self.originalTextView.attributedText mutableCopy];
    [attrOriginalText setAttributes:nil range:NSMakeRange(0, attrOriginalText.length)];
    
    int morseCharacterLength = (int) self.morseLabel.text.length;
    
    
    [attrMorseText setAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor]}
                           range:NSMakeRange(lastMorseEOL,morseCharacterLength + 7)];
    [attrOriginalText setAttributes:@{NSBackgroundColorAttributeName:[UIColor redColor]}
                              range:NSMakeRange(i*8,8)];
    lastMorseEOL = lastMorseEOL + morseCharacterLength + 7;
    
    self.morseTextView.attributedText = attrMorseText;
    self.originalTextView.attributedText = attrOriginalText;
    
}

- (void) didFinishTransmitingMorseArray
{
    [ProgressHUD showSuccess:@"Success!"];
    
    [self clearTextViewMarkers];
    self.startButton.backgroundColor = [UIColor greenColor];
    self.startButton.enabled = YES;
    self.stopButton.backgroundColor = [UIColor grayColor];
    self.stopButton.enabled = NO;
}

- (void) didTransmitCalibration
{
    [ProgressHUD showSuccess:@"Calibrated!"];
}

- (void) willTransmitCalibration
{
    [ProgressHUD showSuccess:@"Calibrating!"];
}


-(void) clearTextViewMarkers {
    NSMutableAttributedString *attrMorseText = [self.morseTextView.attributedText mutableCopy];
    [attrMorseText setAttributes:nil range:NSMakeRange(0,attrMorseText.length)];
    NSMutableAttributedString *attrOriginalText = [self.originalTextView.attributedText mutableCopy];
    [attrOriginalText setAttributes:nil range:NSMakeRange(0, attrOriginalText.length)];
    self.morseTextView.attributedText = attrMorseText;
    self.originalTextView.attributedText = attrOriginalText;
    self.morseLabel.text = nil;
    self.originalCharacterLabel.text = nil;
}



#pragma mark - UITextFieldDelegate



-(void) textFieldDidEndEditing:(UITextField *)textField {

    self.stringToMorsify = textField.text;
    
    [self translateToMorseArrayAndSetTextFieldsWithString:self.stringToMorsify];
    
   
}

- (void) translateToMorseArrayAndSetTextFieldsWithString: (NSString *) string {
    self.morseCodeArray = [self.stringToMorsify morseCodeArray];
    NSMutableString * morseString = [NSMutableString new];
    NSMutableString * originalString = [NSMutableString new];
    
    for (int i = 0; i < self.morseCodeArray.count; i++){
        [morseString appendFormat:@"      %@\n",self.morseCodeArray[i]];
        [originalString appendFormat:@"      %@\n",[self.stringToMorsify substringWithRange:NSMakeRange(i,1)]];
        
    }
    
    self.morseTextView.text = morseString;
    self.originalTextView.text = originalString;
    
    self.morseTextView.textAlignment = NSTextAlignmentRight;
    self.morseTextView.textAlignment = NSTextAlignmentLeft;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void) textFieldDidChange: (UITextField *) sender {
    
    self.stringToMorsify = sender.text;
    
    [self translateToMorseArrayAndSetTextFieldsWithString:self.stringToMorsify];
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //This is a gist by @johnnyclem https://gist.github.com/johnnyclem/8215415 well done!
    for (UIControl *control in self.view.subviews) {
//        if (control == self.startButton) {
//            [self.inputTextField endEditing:YES];
//            [self.inputTextField resignFirstResponder];
//        }
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

- (IBAction)calibrateSwitchCHanged:(UISwitch *)sender {
    self.willCalibrate = sender.on;
}



@end
