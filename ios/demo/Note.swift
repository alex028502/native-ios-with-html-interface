import Foundation

struct Note {
    var note: String
    
    func json() -> [String:String] {
        return ["note":self.note]
    }
}
