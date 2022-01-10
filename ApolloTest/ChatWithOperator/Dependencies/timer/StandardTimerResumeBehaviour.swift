import Foundation


/**
 Calculates fire date by standard way. Fire date is time interval since now between initial expected fire date and pause date.
 
 - author: Q-PPR
 */
public class StandardTimerResumeBehaviour: NSObject, TimerResumeBehaviour {

    public func getFireDateAfterResume(info: TimerPauseInfo) -> Date {
        let expected = info.expectedFireDate.timeIntervalSinceReferenceDate
        let pause = info.pauseDate.timeIntervalSinceReferenceDate
        
        let remaining = expected - pause
        
        return Date(timeIntervalSinceNow: remaining)
    }
}
