//
//  YSMorseCameraController.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/24/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSMorseCameraController.h"
#import "CFMagicEvents.h"
#import "YSAppDelegate.h"
#import "NSString+MorseCode.h"

@interface YSMorseCameraController ()
@property (weak, nonatomic) IBOutlet UITextField *resultTextField;

@property (nonatomic) CFMagicEvents * cfMagicEvents;
@property (nonatomic) NSOperationQueue * detectionQueue;
@property (nonatomic) NSDate * currentStateStart;
@property (nonatomic) NSString * lastDetected;
@property (nonatomic) NSTimeInterval detectedUnit;
@property BOOL firstLight;
@property BOOL isCalibrated;
@property int calibrationCounter;
@property (nonatomic) NSMutableString * morseCharacter;
@property (weak,nonatomic) NSTimer *lastCharacterTimer;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UILabel *capturingLabel;


@end

@implementation YSMorseCameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.cfMagicEvents = [[CFMagicEvents alloc] init];
    self.firstLight = YES;
    self.isCalibrated = NO;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDarknessDetected:) name:@"darknessDetected" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveBrightnessDetected:) name:@"brightnessDetected" object:nil];
}

- (NSMutableString * ) morseCharacter
{
    if (!_morseCharacter) {
        _morseCharacter = [NSMutableString new];
    }
    return _morseCharacter;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startCapturePressed:(UIButton *)sender {
    
    self.lastDetected = @"bright";

    [self.cfMagicEvents startCapture];
    self.startButton.enabled = NO;
    self.startButton.backgroundColor = [UIColor grayColor];
    self.stopButton.enabled = YES;
    self.stopButton.backgroundColor = [UIColor redColor];
    self.capturingLabel.hidden = NO;
}

- (IBAction)stopCapturePressed:(UIButton *)sender {
    [self.cfMagicEvents stopCapture];
    self.morseCharacter = nil;
    self.startButton.backgroundColor = [UIColor greenColor];
    self.startButton.enabled = YES;
    self.stopButton.backgroundColor = [UIColor grayColor];
    self.stopButton.enabled = NO;
    self.capturingLabel.hidden = YES;

}

- (IBAction)resetCalibrationPressed:(UIButton *)sender {
    self.detectedUnit = 0;
    self.calibrationCounter = 0;
    self.isCalibrated = NO;
    self.resultTextField.text = nil;
}

- (IBAction)sensitivitySliderChanged:(UISlider *) sender {
    //If you need tu customize brightness Threshold
    [self.cfMagicEvents updateBrightnessThreshold:sender.value];
}

-(void)receiveDarknessDetected:(NSNotification *) notification
{
//    NSLog(@"Dark");
    if ([self.lastDetected isEqualToString:@"bright"]) {
        NSDate * now = [NSDate date];
        NSTimeInterval diff = [now timeIntervalSinceDate:self.currentStateStart];
        [self didRegisterBrightnessOfInterval:diff];
        
        self.currentStateStart = [NSDate date];
        self.lastDetected = @"dark";
    }
}

-(void)receiveBrightnessDetected:(NSNotification *) notification
{
//    NSLog(@"Bright");
    if (self.firstLight) {
        self.currentStateStart = [NSDate date];
        self.firstLight = NO;
    }
    if ([self.lastDetected isEqualToString:@"dark"]) {
        
        NSDate * now = [NSDate date];
        NSTimeInterval diff = [now timeIntervalSinceDate:self.currentStateStart];
        [self didRegisterDarknessOfInterval:diff];
        
        self.currentStateStart = [NSDate date];
        self.lastDetected = @"bright";
    }
}

- (void) didRegisterDarknessOfInterval:(NSTimeInterval) interval {
    [self.lastCharacterTimer invalidate];
    
    if (self.detectedUnit) {
        float ratio = interval/(self.detectedUnit);
//        NSLog(@" darkness of:%d sec", roundedInterval);
        if ( ratio < 1.8) {
//            NSLog(@"part");
        
        } else if ( ratio > 6) {
//            NSLog(@"word %f",ratio);
            NSString * letter = [self.morseCharacter alphanumericFromMorseCharacter];
//            NSLog(@"Letter was %@",letter);
            if (self.isCalibrated) {
                [self addLetterToResult:letter];
                [self addLetterToResult:@" "];
            }
            self.morseCharacter = nil;
                
        } else if ( ratio > 1.8) {
//            NSLog(@"character %f",ratio);
            NSString * letter = [self.morseCharacter alphanumericFromMorseCharacter];
//            NSLog(@"Letter was %@",letter);
            if (self.isCalibrated) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self addLetterToResult:letter];
                }];
            }
            self.morseCharacter = nil;
            NSLog(@"Message So far:%@", self.resultTextField.text);
        }
    }
    
    
}

- (void) addLetterToResult: (NSString *) letter
{
    if (![letter isEqualToString:@"?"]) {
    self.resultTextField.text = [self.resultTextField.text stringByAppendingString:letter];
    }
}



- (void) didRegisterBrightnessOfInterval:(NSTimeInterval) interval {
    if (!self.isCalibrated) {
        if (self.calibrationCounter > 2) {
            self.detectedUnit = interval;
            NSLog(@"unit is %f",interval);
        }
        self.calibrationCounter++;
        if (self.calibrationCounter > 3) {
            self.isCalibrated = YES;
        }
    } else {
//        NSLog(@"bright length is %f",interval);
        float ratio = interval/(self.detectedUnit);
//        NSLog(@"rounded division is %f",roundedRatio);
        if ( ratio < 1.5) {
            NSLog(@".");
            [self.morseCharacter appendString:@"."];
        } else if ( ratio >= 1.5) {
            NSLog(@"-");
            [self.morseCharacter appendString:@"-"];
        }
        if (!self.lastCharacterTimer) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.lastCharacterTimer = [NSTimer scheduledTimerWithTimeInterval:self.detectedUnit*15 target:self selector:@selector(lastCharacter:) userInfo:nil repeats:NO];
        }];
        }

    }
    
    
}

- (void) lastCharacter:(NSTimer *)timer
{
    NSLog(@"last character");
    NSString * letter = [self.morseCharacter alphanumericFromMorseCharacter];
    NSLog(@"Last Letter was %@",letter);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.resultTextField.text = [self.resultTextField.text stringByAppendingString:letter];
        self.morseCharacter = nil;
    }];
    [self stopCapturePressed:nil];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}



@end
