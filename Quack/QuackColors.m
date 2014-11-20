//
//  QuackColors.m
//  Quack
//
//  Created by Connie Qi on 11/15/14.
//  Copyright (c) 2014 eecs441group. All rights reserved.
//

#import "QuackColors.h"

@implementation UIColor (QuackColors)

+ (UIColor *)quackSeaColor {
    static UIColor *seaColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        seaColor = [UIColor colorWithRed:16.0 / 255.0
                                   green:196.0 / 255.0
                                    blue:237.0 / 255.0
                                   alpha:1.0];
    });
    
    return seaColor;
}

+ (UIColor *)quackWaveColor {
    static UIColor *waveColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        waveColor = [UIColor colorWithRed:79.0 / 255.0
                                   green:210.0 / 255.0
                                    blue:240.0 / 255.0
                                   alpha:1.0];
    });
    
    return waveColor;
}

+ (UIColor *)quackFoamColor {
    static UIColor *foamColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        foamColor = [UIColor colorWithRed:207.0 / 255.0
                                    green:243.0 / 255.0
                                     blue:251.0 / 255.0
                                    alpha:1.0];
    });
    
    return foamColor;
}

+ (UIColor *)quackShellColor {
    static UIColor *shellColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shellColor = [UIColor colorWithRed:248.0 / 255.0
                                    green:248.0 / 255.0
                                     blue:248.0 / 255.0
                                    alpha:1.0];
    });
    
    return shellColor;
}

+ (UIColor *)quackCharcoalColor {
    static UIColor *charcoalColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        charcoalColor = [UIColor colorWithRed:51.0 / 255.0
                                    green:51.0 / 255.0
                                     blue:51.0 / 255.0
                                    alpha:1.0];
    });
    
    return charcoalColor;
}

+ (UIColor *)quackSandColor {
    static UIColor *sandColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sandColor = [UIColor colorWithRed:255.0 / 255.0
                                    green:222.0 / 255.0
                                     blue:108.0 / 255.0
                                    alpha:1.0];
    });
    
    return sandColor;
}

+ (UIColor *)quackGreenColor {
    static UIColor *greenColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        greenColor = [UIColor colorWithRed:57.0 / 255.0
                                    green:214.0 / 255.0
                                     blue:180.0 / 255.0
                                    alpha:1.0];
    });
    
    return greenColor;
}

+ (UIColor *)quackNavyColor {
    static UIColor *navyColor;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navyColor = [UIColor colorWithRed:0.0 / 255.0
                                     green:0.0 / 255.0
                                      blue:89.0 / 255.0
                                     alpha:1.0];
    });
    
    return navyColor;
}


@end