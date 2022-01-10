import Foundation


/**
 Encapsulates information about pause event.
 
 - author: Q-PPR
 */
public struct TimerPauseInfo {
    
    let pauseDate: Date
    let expectedFireDate: Date
    
    public init(pauseDate: Date, expectedFireDate: Date) {
        self.pauseDate = pauseDate
        self.expectedFireDate = expectedFireDate
    }
}
