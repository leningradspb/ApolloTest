import Foundation


enum TimerState {
    case stopped
    case running
    case paused
}


public typealias TimerFireHandler = () -> Void


/**
 Implementation of lifecycle timer.
 Supports different behaviour of calculation fire time after pause/resume.
 
 - author: Q-PPR
 */
public class DefaultLifecycleTimer: NSObject, LifecycleTimer {
    
    private let timeInterval: TimeInterval
    private let handler: TimerFireHandler
    private let resumeBehaviour: TimerResumeBehaviour
    
    private var state: TimerState = .stopped
    
    private var timer: Timer?
    
    private var pauseInfo: TimerPauseInfo?
    
    public init(timeInterval: TimeInterval,
         resumeBehaviour: TimerResumeBehaviour = StandardTimerResumeBehaviour(),
         handler: @escaping TimerFireHandler) {
        
        self.timeInterval = timeInterval
        self.handler = handler
        self.resumeBehaviour = resumeBehaviour
    }
    
    @objc public func start() {
        guard state == .stopped else {
            return
        }
        
        run()
        
        state = .running
    }
    
    @objc public func stop() {
        guard state != .stopped else {
            return
        }
        
        invalidate()
        
        state = .stopped
    }
    
    @objc public func pause() {
        guard let timer = timer, state == .running else {
            return
        }

        pauseInfo = TimerPauseInfo(pauseDate: Date(), expectedFireDate: timer.fireDate)
        invalidate()
        
        state = .paused
    }
    
    @objc public func resume() {
        guard state == .paused else {
            return
        }
        
        let fireDate = resumeBehaviour.getFireDateAfterResume(info: pauseInfo!)
        run(fireDate: fireDate)
        
        pauseInfo = nil
        
        state = .running
    }
    
    @objc func onTimerFire() {
        stop()
        handler()
    }
    
    private func run(fireDate: Date? = nil) {
        let timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(onTimerFire),
                      userInfo: nil, repeats: false)
        
        if let fireDate = fireDate {
            timer.fireDate = fireDate
        }
        
        RunLoop.current.add(timer, forMode: RunLoop.Mode.default)

        self.timer = timer
    }
    
    private func invalidate() {
        timer?.invalidate()
        timer = nil
    }
}
