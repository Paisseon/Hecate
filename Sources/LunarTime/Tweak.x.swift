import Orion
import LunarTimeC
import UIKit

func getPhase() -> String {
	var phaseEmoji = ""
	
	let fdate = DateFormatter()
	fdate.dateFormat = "d M yyyy" // e.g. "22 09 2017"
	let date = fdate.string(from: Date()).components(separatedBy: " ") // ["22", "09", "2017"]
	
	let day = Double(date[0]) ?? 22.0 // convert string to double for use in calculations
	let month = Double(date[1]) ?? 09.0 // read above
	let year = Double(date[2]) ?? 2021.0 // read above
	
	let daysInYear = year * 365.25 // get the number of days in a year, accounting for leap years
	let daysInMonth = month * 30.6 // get the number of days in a month
	var julian = ((daysInMonth + daysInYear + day) - 694039.09) / 29.53 // quick maths
	julian -= Double(Int(julian)) // get only the digits after the decimal point
	let phase = Int(julian * 8 + 0.5) & 7 // quick maths pt 2
		
	switch (phase) {
		case 0:
			phaseEmoji = "🌑" // new moon
		case 1:
			phaseEmoji = "🌒" // waxing crescent
		case 2:
			phaseEmoji = "🌓" // first quarter
		case 3:
			phaseEmoji = "🌔" // waxing gibbous
		case 4:
			phaseEmoji = "🌕" // full moon
		case 5:
			phaseEmoji = "🌖" // waning gibbous
		case 6:
			phaseEmoji = "🌗" // last quarter
		case 7:
			phaseEmoji = "🌘" // waning crescent
		default:
			phaseEmoji = "🍓" // strawberry panic!
	}
	
	return phaseEmoji
}

class StatusHook: ClassHook<UILabel> {
	static let targetName = "_UIStatusBarStringView"
	
	func setText(_ arg0: String) {
		let labelIsDate = Array(arg0)[arg0.count - 1] == "." // string -> array -> string to check if last character is a period
	
		if arg0.contains(":") || (arg0.contains(".") && labelIsDate == false) { // if this is a time label
			orig.setText("\(arg0) \(getPhase())") // e.g. "04.20 🌗"
		} else {
			orig.setText(arg0)
		}
	}
}

class BSCHook: ClassHook<UILabel> {
	func setText(_ arg0: String) {
		if arg0.contains(":") && target.superview is UIStackView { // if it is the time in BigSurCenter's status bar
			orig.setText("\(arg0) \(getPhase())") // e.g. "04:20 🌗" because bsc doesn't have dot times
		} else {
			orig.setText(arg0)
		}
	}
}