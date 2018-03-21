//
//  NSMenuExtraBase.h
//  MenuMeters
//
//  Created by Yuji on 2015/08/01.
//
//

#import <Foundation/Foundation.h>
#import "AppleUndocumented.h"
#import "MenuMeterDefaults.h"

#define USE_TIMER_MANAGER 1

@interface MenuMetersMenuExtraBase : NSMenuExtra <NSMenuDelegate>
{
    NSStatusItem* statusItem;
#if !USE_TIMER_MANAGER
    NSTimer* updateTimer;
#endif
}
- (void)configDisplay:(NSString*)bundleID fromPrefs:(MenuMeterDefaults*)ourPrefs withTimerInterval:(NSTimeInterval)interval;
- (void)timerFired:(id)timer;

@property(nonatomic, readonly) BOOL requiresRedraw;
@property(nonatomic, readonly) BOOL isMenuVisible;
@end

#define NSMenuExtra MenuMetersMenuExtraBase
