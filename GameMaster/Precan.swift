//
//  Precan.swift
//  GameMaster
//
//  Created by Matt Ao on 4/23/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

public let PrecanType = "Precan"

class Precan: NSObject {
    var identifier: CKRecordID?
    var room: String?
    var precanString: String?
    
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
        if let precanString = record.value(forKey: "precanString") as? String {
            self.precanString = precanString
        }
        self.identifier = record.recordID
    }
    
    func record() -> CKRecord? {
        var record: CKRecord
        if let id = identifier {
            record = CKRecord(recordType: PrecanType, recordID: id)
        } else {
            record = CKRecord(recordType: PrecanType)
        }
        
        record.setValue(room, forKey:"room")
        record.setValue(precanString, forKey: "precanString")
        
        return record
    }
    
    static func ==(first: Precan, second: Precan) -> Bool {
        return first.identifier == second.identifier
    }
    
}

