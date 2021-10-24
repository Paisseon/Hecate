#import "LunarTime.h"

static NSString* getLunarPhase() {
	NSString* phaseEmoji;
	int day = [[NSCalendar currentCalendar] component:NSCalendarUnitDay fromDate:[NSDate date]]; // get the day of month
	int month = [[NSCalendar currentCalendar] component:NSCalendarUnitMonth fromDate:[NSDate date]]; // get the month
	int year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:[NSDate date]]; // get the year
	int daysInYear = year * 365.25; // calculate the number of days since 0 AD
	int daysInMonth = month * 30.6; // calculate the number of days this year
	double julian = ((daysInMonth + daysInYear + day) - 694039.09) / 29.53; // total days since 0 AD divided by lunar cycle
	int phase = julian; // get integer of the julian date
	julian -= phase; // and subtract the integer leaving only decimals
	phase = (int)(julian * 8 + 0.5) & 7; // round into the 8 sections for lunar phases
	switch (phase) {
		case 0:
			phaseEmoji = @"🌑"; // new moon
		case 1:
			phaseEmoji = @"🌒"; // waxing crescent
		case 2:
			phaseEmoji = @"🌓"; // first quarter
		case 3:
			phaseEmoji = @"🌔"; // waxing gibbous
		case 4:
			phaseEmoji = @"🌕"; // full moon
		case 5:
			phaseEmoji = @"🌖"; // waning gibbous
		case 6:
			phaseEmoji = @"🌗"; // last quarter
		case 7:
			phaseEmoji = @"🌘"; // waning crescent
	}
	return phaseEmoji; // return the emoji of the current lunar phase
}

%hook _UIStatusBarStringView
- (void) setText: (NSString*) arg0 {
	bool labelIsDate = ([[arg0 substringFromIndex:[arg0 length] -1] isEqualToString:@"."]); // check if the string ends with a dot
	// what this does is to check for the time so we don't mess with the carrier and other things.
	if (!labelIsDate && ([arg0 containsString:@":"] || [arg0 containsString:@"."])) arg0 = [NSString stringWithFormat:@"%@ %@", arg0, getLunarPhase()]; // show original time with phase at the end, e.g. "04.20 🌖"
	%orig;
}
%end

%hook UILabel
- (void) setText: (NSString*) arg0 {
	if ([self.superview isKindOfClass:[UIStackView class]] && [arg0 containsString:@":"]) {
		arg0 = [NSString stringWithFormat:@"%@ %@", arg0, getLunarPhase()]; // this does the same thing but for the BigSurCenter status bar
	}
	%orig;
}
%end