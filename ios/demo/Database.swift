//let's keep the database simple for this project

import UIKit

protocol Database {
    func insert(_: Note)
    func select() -> [Note]
    func deleteAll()
}

class OnDiskDatabase: Database {
    //this implementation can only store one line items
    //that is pointed out in the tests
    //so it can be improved if needed
    //like by switching to json
    
    //sometimes unit tests allow you to fearlessly refactor you code to perfection
    //but sometimes they allow you do the exact opposite: fearlessly throw in line
    //break here, skip a blank line there, return an empty string....
    
    var dataFile: String
    
    init(dataFile: String) {
        self.dataFile = dataFile
    }
    
    convenience init() {
        self.init(dataFile: "productionDB.txt")
    }
    
    func insert(note: Note) {
        let text = self.rawData + "\n" + note.note
        try! text.writeToFile(self.dataFilePath, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    func select() -> [Note] {
        let raw_notes = self.rawData.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        var selection: [Note] = []
        for raw_note in raw_notes {
            if (raw_note != "") {
                selection.append(Note(note:raw_note))
            }
        }
        return selection
    }
    
    private var rawData: String {
        get {
            do {
                return try String(contentsOfFile:self.dataFilePath, encoding: NSUTF8StringEncoding)
            } catch {
                return ""
            }
        }
    }
    
    var dataFilePath: String {
        get {
            return self.documentsDirectory + "/" + self.dataFile
        }
    }
    
    var documentsDirectory: String {
        get {
            //thanks https://www.hackingwithswift.com/example-code/strings/writetofile-how-to-save-a-string-to-a-file-on-disk
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
    }
    
    func deleteAll() {
       _ = try? NSFileManager.defaultManager().removeItemAtPath(self.dataFilePath)
    }
}

class MockDatabase: Database {
    var data: [Note] = []
    
    func insert(note: Note) {
        self.data.append(note)
    }
    
    func select() -> [Note] {
        return self.data
    }
    
    func deleteAll() {
        self.data = []
    }
}

//thanks http://stackoverflow.com/a/24110512/5203563
extension Database {
    func json() -> [[String:String]] {
        var output: [[String:String]] = []
        for note in self.select() {
            output.append(note.json())
        }
        return output
    }
}