//
//  YSTorchController.m
//  MorseTorch
//
//  Created by Yair Szarf on 1/21/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import "YSTorchController.h"

@interface YSTorchController (){
    BOOL torchIsOn;
    
    
}
@property (weak,nonatomic) AVCaptureDevice * device;

@end

@implementation YSTorchController

+(YSTorchController *) sharedTorch{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            static dispatch_once_t pred;
            static YSTorchController *shared = nil;
            
            dispatch_once(&pred, ^{
                shared = [[YSTorchController alloc] init];
            });
            shared.device = device;
            return shared;
        } else return nil;
    
}

-(void) torchOn
{
    
    if (!torchIsOn) {
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOn];
        [self.device setFlashMode:AVCaptureFlashModeOn];
        [self.device unlockForConfiguration];
        torchIsOn= YES;
    }
}

-(void) torchOff
{
    if (torchIsOn) {
        [self.device lockForConfiguration:nil];
        [self.device setTorchMode:AVCaptureTorchModeOff];
        [self.device setFlashMode:AVCaptureFlashModeOff];
        [self.device unlockForConfiguration];
        torchIsOn= NO;
    }
    
}





@end
