
#import <Foundation/Foundation.h>

@class MenuMetersMenuExtraBase;

@interface TimerManager : NSObject

+ (TimerManager*) sharedTimerManager;

- (void)scheduleTimerWithInterval:(NSTimeInterval)timeInterval target:(MenuMetersMenuExtraBase*)target;
- (void)invalidateTimerForTarget:(MenuMetersMenuExtraBase*)target;

- (void)timerFired:(id)timer;

@end
