import Foundation


/**
 Protocol to calculate fire date after resume. Assumes that resume date is date of calling calculation method.
 
 - author: Q-PPR
 */
public protocol TimerResumeBehaviour {
    
    func getFireDateAfterResume(info: TimerPauseInfo) -> Date
}
