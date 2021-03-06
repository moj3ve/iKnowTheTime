@interface SBDashBoardTodayPageView
	@property (nonatomic,retain) UIView * todayView;
	@property (nonatomic,retain) UIScrollView * widgetMajorScrollView;
@end

@interface FBSystemService : NSObject
  +(id)sharedInstance;
  -(void)exitAndRelaunch:(BOOL)arg1;
@end


@interface CSTodayPageView : UIView
	@property (nonatomic,retain) UIScrollView * widgetMajorScrollView;
@end

@interface CSTodayViewController
	@property (nonatomic,retain) CSTodayPageView * view;
@end

static double portraitVal = 90;

//iOS13
// %hook CSTodayViewController

// 	-(void)_updateAppearanceForScrollView:(id)arg1
// 	{
// 		%orig;
// 		if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)
// 		{
// 			[arg1 setContentInset:UIEdgeInsetsMake(portraitVal,0,0,0)];
// 		}
// 	}

// 	-(void)_updateAppearanceForScrollView:(id)arg1 animated:(BOOL)arg2
// 	{
// 		%orig;
// 		if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)
// 		{
// 			[arg1 setContentInset:UIEdgeInsetsMake(portraitVal,0,0,0)];
// 		}
// 	}

// %end
@interface WGWidgetListHeaderView : UIView
@end

%hook WGWidgetListHeaderView

	-(void)layoutSubviews
	{
		%orig;
		[self removeFromSuperview];
	}
%end
// %hook CSLayoutStrategy
//
// 	-(CGRect)suggestedFrameForListForPage:(id)arg1 bounds:(CGRect)arg2
// 	{
// 		CGRect orig = %orig;
// 		orig.origin.y = orig.origin.y - portraitVal;
// 		return orig;
// 	}
//
// %end

//%hook CSCoverSheetView
//	- (void) setDateViewPageAlignment:(long)alignment {
//
//				if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)
//				{
//					[arg1 setContentInset:UIEdgeInsetsMake(portraitVal,0,0,0)];
//				}
//		%orig(0);
//	}
//%end

//iOS 12
%hook SBDashBoardView
	- (void) setDateViewPageAlignment:(long)alignment {
		%orig(0);
	}
%end

%hook SBDashBoardTodayPageView

	-(void)_updateContentInsetsForScrollView:(id)arg1 snapsToRestingPositions:(BOOL)arg2
	{
		%orig;

		if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait)
		{
			[arg1 setContentInset:UIEdgeInsetsMake(portraitVal,0,0,0)];
		}
	}
%end

static void loadPreferences() {
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.p2kdev.iknowthetime.plist"];
	if (prefs) {
		portraitVal = [prefs objectForKey:@"portraitOffset"] ? [[prefs objectForKey:@"portraitOffset"] doubleValue] : portraitVal;
		//landscapeVal = [prefs objectForKey:@"landscapeOffset"] ? [[prefs objectForKey:@"landscapeOffset"] intValue] : landscapeVal;
	}
	[prefs release];
}

static void respring(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [[%c(FBSystemService) sharedInstance] exitAndRelaunch:YES];
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPreferences, CFSTR("com.p2kdev.iknowthetime.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, respring, CFSTR("com.p2kdev.iknowthetime.respring"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPreferences();
}
