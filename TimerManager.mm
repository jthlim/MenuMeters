
#import "TimerManager.h"

static int GCD(int a, int b)
{
	while (a != b)
	{
		if(a > b) a -= b;
		else b -= a;
	}
	return a;
}

struct TimerElement
{
	MenuMetersMenuExtraBase *__unsafe_unretained target;
	float   interval;
	int		resetCount;
	int		countdown;
	
	TimerElement() { target = nil;	}
};

class TimerElementManager
{
public:
	void ScheduleTimer(double interval, MenuMetersMenuExtraBase *__unsafe_unretained target);
	void CancelTimer(MenuMetersMenuExtraBase *__unsafe_unretained target);
	
	double GetUpdateInterval() const { return interval; }
	
	void Update(id timer);
	
private:
	int			 numberOfElements = 0;
	TimerElement elements[4];
	double		 interval = 0;
	
	void UpdateInterval();
};

void TimerElementManager::ScheduleTimer(double interval, MenuMetersMenuExtraBase *__unsafe_unretained target)
{
	for(int i = 0; i < numberOfElements; ++i)
	{
		if(elements[i].target == target)
		{
			elements[i].interval = interval;
			UpdateInterval();
			return;
		}
	}
	
	TimerElement& element = elements[numberOfElements++];
	element.target = target;
	element.interval = interval;
	UpdateInterval();
}

void TimerElementManager::CancelTimer(MenuMetersMenuExtraBase *__unsafe_unretained target)
{
	for(int i = 0; i < numberOfElements; ++i)
	{
		if(elements[i].target == target)
		{
			--numberOfElements;
			for(int j = i; j < numberOfElements; ++j)
			{
				elements[j] = elements[j+1];
			}
			UpdateInterval();
			return;
		}
	}
}

void TimerElementManager::UpdateInterval()
{
	if(numberOfElements == 0)
	{
		interval = 0;
		return;
	}
	
	int microseconds = (int) round(elements[0].interval * 1000);
	for(int i = 1; i < numberOfElements; ++i)
	{
		int elementMicroseconds = (int) round(elements[i].interval * 1000);
		microseconds = GCD(microseconds, elementMicroseconds);
	}
	
	interval = microseconds * 0.001f;
	
	for(int i = 0; i < numberOfElements; ++i)
	{
		elements[i].countdown = 1;
		elements[i].resetCount = (int) round(elements[i].interval / interval);
	}
}

void TimerElementManager::Update(id timer)
{
	for(int i = 0; i < numberOfElements; ++i)
	{
		if(--elements[i].countdown <= 0)
		{
			elements[i].countdown = elements[i].resetCount;
			[elements[i].target timerFired:timer];
		}
	}
}

static TimerManager* timerManager;
static TimerElementManager timerElementManager;

@interface TimerManager ()
{
	NSTimer* _updateTimer;
}
@end

@implementation TimerManager

+ (TimerManager*) sharedTimerManager {
	if(!timerManager) {
		timerManager = [[TimerManager alloc] init];
	}
	return timerManager;
}

- (void)scheduleTimerWithInterval:(NSTimeInterval)timeInterval target:(MenuMetersMenuExtraBase*)target {
	timerElementManager.ScheduleTimer(timeInterval, target);
	[self updateTimer];
}

- (void)invalidateTimerForTarget:(MenuMetersMenuExtraBase*)target {
	timerElementManager.CancelTimer(target);
	[self updateTimer];
}

- (void)timerFired:(id)timer {
	timerElementManager.Update(timer);
}

- (void)updateTimer {
	[_updateTimer invalidate];
	_updateTimer = nil;
	
	double interval = timerElementManager.GetUpdateInterval();
	if(interval != 0)
	{
		_updateTimer = [NSTimer timerWithTimeInterval:interval
											   target:self
											 selector:@selector(timerFired:)
											 userInfo:nil
											  repeats:YES];
		[_updateTimer setTolerance:0.2 * interval];
		[[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
	}
}

@end
