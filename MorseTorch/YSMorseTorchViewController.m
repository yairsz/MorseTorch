//
//  YSViewController.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseTorchViewController.h"

@interface YSMorseTorchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UITextView *originalTextView;


@end

@implementation YSMorseTorchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    NSString * inputText = textField.text;
    NSArray * morseArray = [inputText morseCodeArray];
    NSMutableString * morseString = [NSMutableString new], *originalString = [NSMutableString new];
    
    for (int i = 0; i < morseArray.count; i++){
        [morseString appendFormat:@"      %@\n",morseArray[i]];
        [originalString appendFormat:@"      %@\n",[inputText substringWithRange:NSMakeRange(i,1)]];
        
    }

    self.outputTextView.text = morseString;
    self.originalTextView.text = originalString;
    
    self.outputTextView.textAlignment = NSTextAlignmentRight;
    self.outputTextView.textAlignment = NSTextAlignmentLeft;

    
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

#pragma mark - UITextViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.outputTextView) {
        self.originalTextView.contentOffset = scrollView.contentOffset;
    } else if (scrollView == self.originalTextView){
        self.outputTextView.contentOffset = scrollView.contentOffset;
        
    }
    
}



@end
