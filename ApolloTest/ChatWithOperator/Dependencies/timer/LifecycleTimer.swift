import Foundation

/**
 Protocol of timer that supports such functions as start, stop, pause, resume.
 Motivation is that system timer doesn't support these functions.
 
 - author: Q-PPR
 */
public protocol LifecycleTimer {
    
    func start()
    
    func stop()
    
    func pause()
    
    func resume()
}
