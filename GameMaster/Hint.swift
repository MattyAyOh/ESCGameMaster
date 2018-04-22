//
//  Hint.swift
//  ESCHints
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

class Hint: NSObject {
    var identifier: CKRecordID?
    var room: String?
    var hintString: String?
    
    override init() {
        if let roomString = UserDefaults().object(forKey: "room") as? String {
            room = roomString
        } else {
            print("Error: No Room Set")
        }
    }
    
    init(record: CKRecord) {
        if let room = record.value(forKey: "room") as? String {
            self.room = room
        }
        if let hintString = record.value(forKey: "hintString") as? String {
            self.hintString = hintString
        }
        self.identifier = record.recordID
    }
    
    func record() -> CKRecord? {
        var record: CKRecord
        if let id = identifier {
            record = CKRecord(recordType: HintType, recordID: id)
        } else {
            record = CKRecord(recordType: HintType)
        }
        
        record.setValue(room, forKey:"room")
        record.setValue(hintString, forKey: "hintString")
        
        return record
    }
    
    static func ==(first: Hint, second: Hint) -> Bool {
        return first.identifier == second.identifier
    }
    
}
