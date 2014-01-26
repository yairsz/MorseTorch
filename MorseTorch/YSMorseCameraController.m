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

@interface YSMorseCameraController ()

@property (nonatomic) CFMagicEvents * cfMagicEvents;
@property (nonatomic) NSOperationQueue * detectionQueue;
@property (nonatomic) NSDate * currentStateStart;
@property (nonatomic) NSString * lastDetected;
@property (nonatomic) NSTimeInterval detectedUnit;
@property BOOL firstLight;
@property int calibrationCounter;


@end

@implementation YSMorseCameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.cfMagicEvents = [[CFMagicEvents alloc] init];
    self.firstLight = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDarknessDetected:) name:@"darknessDetected" object:nil];
////
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveBrightnessDetected:) name:@"brightnessDetected" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startCapturePressed:(UIButton *)sender {
    
    self.lastDetected = @"bright";

    [self.cfMagicEvents startCapture];
}

- (IBAction)stopCapturePressed:(UIButton *)sender {
    [self.cfMagicEvents stopCapture];

}

- (IBAction)resetCalibrationPressed:(UIButton *)sender {
    self.detectedUnit = 0;
    self.calibrationCounter = 0;
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
    if (self.detectedUnit) {
        float roundedRatio = interval/(self.detectedUnit);
//        NSLog(@" darkness of:%d sec", roundedInterval);
        if ( roundedRatio < 1.8) {
            NSLog(@"part");
        } else if ( roundedRatio > 6) {
            NSLog(@"Word");
        } else if ( roundedRatio > 1.8) {
            NSLog(@"Character");
        }
    }
    
    
}

- (void) didRegisterBrightnessOfInterval:(NSTimeInterval) interval {
    if (!self.detectedUnit) {
        if (self.calibrationCounter > 2) {
            self.detectedUnit = interval;
            NSLog(@"unit is %f",interval);
        }
        self.calibrationCounter++;
    } else {
//        NSLog(@"bright length is %f",interval);
        float roundedRatio = interval/(self.detectedUnit);
//        NSLog(@"rounded division is %f",roundedRatio);
        if ( roundedRatio < 1.5) {
            NSLog(@".");
        } else if ( roundedRatio >= 1.5) {
            NSLog(@"-");
        }
    }
}

@end
