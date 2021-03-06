//
//  YSAppDelegate.h
//  MorseTorch
//
//  Created by Yair Szarf on 1/20/14.
//  Copyright (c) 2014 The 2 Handed Consortium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSTorchController.h"
#import "CFMagicEvents.h"

@interface YSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YSTorchController *sharedTorch;
@property (nonatomic) CFMagicEvents * cfMagicEvents;


@end
