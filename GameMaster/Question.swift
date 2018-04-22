//
//  Question.swift
//  ESCHints
//
//  Created by Matt Ao on 4/22/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

public let QuestionType = "Question"

class Question: NSObject {
    var identifier: CKRecordID?
    var room: String?
    var questionString: String?
    
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
        if let questionString = record.value(forKey: "questionString") as? String {
            self.questionString = questionString
        }
        self.identifier = record.recordID
    }
    
    func record() -> CKRecord? {
        var record: CKRecord
        if let id = identifier {
            record = CKRecord(recordType: QuestionType, recordID: id)
        } else {
            record = CKRecord(recordType: QuestionType)
        }
        
        record.setValue(room, forKey:"room")
        record.setValue(questionString, forKey: "questionString")
        
        return record
    }
    
    static func ==(first: Question, second: Question) -> Bool {
        return first.identifier == second.identifier
    }
    
}

