/**
 Перечисление с возможными типами процессов инициированных оператором в чате.
 */
enum OperatorInitiatedProcessType: String, RawRepresentable, CaseIterable {
    
    /**
     Процесс формирования заявления в свободной форме.
     */
    case claimFreeForm = "claimsFreeForm_startProcess"
    
    /**
     Процесс изменения персональных данных пользователя.
     */
    case changePersonalData = "actuality_startProcess"
    
    /**
     Функционал переведен на след. итерацию.
    
    /**
     Процесс пролонгации Каско.
     */
    case kaskoAuto = "kaskoRosbankAuto_startProcess"
    
    /**
     Процесс создания запроса в Росбанк Авто.
     */
    case pledgeAuto = "pledgeRosbankAuto_startProcess"
    
    /**
     Процесс сообщения о проблеме.
     */
    case incident = "incidentRosbankOnline_startProcess"
     */
    
    /**
     - Returns: Все возможные rawValue перечисления.
     */
    static func getRawValues() -> [String] {
        return Self.allCases.map { $0.rawValue }
    }
}
