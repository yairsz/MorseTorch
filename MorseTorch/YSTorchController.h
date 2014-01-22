//
//  YSTorchController.h
//  MorseTorch
//
//  Created by Yair Szarf on 1/21/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface YSTorchController : NSObject

//Controller will only be created if device has a torch available
+ (YSTorchController *) sharedTorch;
- (void) torchOn;
- (void) torchOff;


@end
