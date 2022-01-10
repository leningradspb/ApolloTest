import Foundation

class ActivityConverter {
    
    static func convert(_ activity: ActivityByFirstMessageResponse) -> Activity? {
        guard let id = activity.id,
            let state = activity.state else {
                return nil
        }
        return Activity(id: id, state: state)
    }
    
    static func convert(_ activity: ActivityInActivityGet) -> Activity? {
        guard let id = activity.id,
            let state = activity.state
            else {
                return nil
                
        }
        return Activity(id: id, state: state)
    }
}
