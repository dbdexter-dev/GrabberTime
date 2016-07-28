#define GRABBER_BOUNDS [[self.viewController grabberView] bounds]

@interface SBNotificationCenterViewController : UIViewController
-(UIView*) grabberView;
@end

@interface SBNotificationCenterController : UIViewController
@property(readonly, nonatomic) SBNotificationCenterViewController *viewController; 
@end

@interface SpringBoard : UIApplication
@property(nonatomic) BOOL batterySaverModeActive;
@end

@interface SBUIController : UIViewController
+(SBUIController*) sharedInstance;
-(float) batteryCapacity;
-(int)batteryCapacityAsPercentage;
-(BOOL)isOnAC;
@end

UILabel* timeLabel = nil;
UIView* batteryBar = nil;
BOOL shouldUnhide = YES;

%hook SBNotificationCenterController
-(void)_setGrabberEnabled:(BOOL)arg1 {
	if(((UIView*)[self.viewController grabberView]).hidden) {
			shouldUnhide = NO;
			((UIView*)[self.viewController grabberView]).hidden = NO;
		} else {
			shouldUnhide = YES;
		}
	if(arg1 == YES) {
		((UIView*)[self.viewController grabberView].subviews[0]).hidden = YES;
		NSDateFormatter* formatDate = [[NSDateFormatter alloc]init];
		[formatDate setTimeStyle: NSDateFormatterShortStyle];
			
		timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(-9, 3,
															GRABBER_BOUNDS.size.width+18,
															GRABBER_BOUNDS.size.height)];
		timeLabel.text = [formatDate stringFromDate:[NSDate date]];
		[timeLabel setTextAlignment:UITextAlignmentCenter];
		[timeLabel setFont:[UIFont systemFontOfSize:12.00]];
		timeLabel.textColor = [UIColor whiteColor];
		
		batteryBar = [[UIView alloc]initWithFrame:CGRectMake(timeLabel.frame.origin.x+1, -3, timeLabel.frame.size.width-1, 2)];
		batteryBar.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
		
		UIView* batteryBarFill = [[UIView alloc]initWithFrame:CGRectMake(1, 0.5, (batteryBar.frame.size.width-1) * [[%c(SBUIController) sharedInstance]batteryCapacity], 1)];
		
		batteryBarFill.backgroundColor = ([[%c(SBUIController) sharedInstance]batteryCapacityAsPercentage] > 20 ? 							//If above 20%
										 ([[%c(SBUIController) sharedInstance]isOnAC] ? [UIColor greenColor] : 
									     [UIColor whiteColor]) :		//If charging, color is green, otherwise white
										 [UIColor redColor]);
		
		if([(SpringBoard*)[UIApplication sharedApplication] respondsToSelector:@selector(batterySaverModeActive)]) {
			if(((SpringBoard*)[UIApplication sharedApplication]).batterySaverModeActive){
				batteryBarFill.backgroundColor = [UIColor yellowColor];
			}
		}

		[batteryBar addSubview:batteryBarFill];
		[batteryBarFill release];
		[formatDate release];
		[[self.viewController grabberView] addSubview:timeLabel];
		[[self.viewController grabberView] addSubview:batteryBar];	
	} else {
		if(timeLabel != nil) {
			[timeLabel removeFromSuperview];
			[timeLabel release];
			[batteryBar removeFromSuperview];
			[batteryBar release];
			timeLabel = nil;
			batteryBar = nil;
		}
	}
	%orig(arg1);
}

-(void) _setupForViewPresentation {
	if(shouldUnhide)
		((UIView*)[self.viewController grabberView].subviews[0]).hidden = NO;
	else
		((UIView*)[self.viewController grabberView]).hidden = YES;
	if(timeLabel != nil) {
		[timeLabel removeFromSuperview];
		[timeLabel release];
		[batteryBar removeFromSuperview];
		[batteryBar release];
		timeLabel = nil;
		batteryBar = nil;
	}
	%orig;
}
%end