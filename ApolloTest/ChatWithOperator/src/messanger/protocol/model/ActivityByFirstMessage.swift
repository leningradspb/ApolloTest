import Foundation

class ActivityByFirstMessage {
    
    let activity: Activity?
    let message: ChatMessage?
    
    init(activity: ActivityByFirstMessageResponse) {
        self.activity = ActivityConverter.convert(activity)
        self.message = ChatMessageConverter.convert(activity: activity)
    }
}
