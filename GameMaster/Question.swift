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
    var hasBeenAnswered: Int64?
    
    override init() {
        // Game master can't create questions
        hasBeenAnswered = 0
    }
    
    init(record: CKRecord) {
        if let room = record.value(forKey: "room") as? String {
            self.room = room
        }
        if let questionString = record.value(forKey: "questionString") as? String {
            self.questionString = questionString
        }
        if let hasBeenAnswered = record.value(forKey: "hasBeenAnswered") as? Int64 {
            self.hasBeenAnswered = hasBeenAnswered
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
        record.setValue(hasBeenAnswered, forKey: "hasBeenAnswered")
        
        return record
    }
    
    static func ==(first: Question, second: Question) -> Bool {
        return first.identifier == second.identifier
    }
    
}

