//
//  ViewController.swift
//  GameMaster
//
//  Created by Matt Ao on 4/19/18.
//  Copyright © 2018 Matt Ao. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase
    
    var hints = [Hint]()
    var questions = [Question]()
    var precannedHints = [Precan]()
    
    @IBOutlet weak var hintsContainer: UIView!
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var precannedHintsTableView: UITableView!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var previousHintsTableView: UITableView!
    @IBOutlet weak var questionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var precannedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previousActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllQuestions()
        fetchAllPrecans()
        fetchAllHints()
        
        let tables = [questionsTableView, precannedHintsTableView, previousHintsTableView]
        for table in tables {
            table?.tableFooterView = UIView()
            table?.layer.cornerRadius = 10
            table?.layer.masksToBounds = true
        }
        
        hintsContainer.layer.cornerRadius = 10
        hintsContainer.layer.masksToBounds = true
        
        hintTextView.layer.cornerRadius = 10
        hintTextView.layer.masksToBounds = true
        hintTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func fetchAllQuestions() {
        questionsTableView.isHidden = true
        questionsActivityIndicator.isHidden = false
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: QuestionType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Questions: \(error)")
                }
                return
            }
            
            if let allQuestions = records?.map(Question.init) {
                self.questions = allQuestions
                DispatchQueue.main.async {
                    self.questionsActivityIndicator.isHidden = true
                    self.questionsTableView.isHidden = false
                    self.questionsTableView.reloadData()
                }
            }
        }
    }
    
    func fetchAllPrecans() {
        precannedHintsTableView.isHidden = true
        precannedActivityIndicator.isHidden = false
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PrecanType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Precans: \(error)")
                }
                return
            }
            
            if let allPrecans = records?.map(Precan.init) {
                self.precannedHints = allPrecans
                DispatchQueue.main.async {
                    self.precannedActivityIndicator.isHidden = true
                    self.precannedHintsTableView.isHidden = false
                    self.precannedHintsTableView.reloadData()
                }
            }
        }
    }
    
    func fetchAllHints() {
        previousHintsTableView.isHidden = true
        previousActivityIndicator.isHidden = false
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: HintType, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Hints: \(error)")
                }
                return
            }
            
            if let allHints = records?.map(Hint.init) {
                self.hints = allHints
                DispatchQueue.main.async {
                    self.previousActivityIndicator.isHidden = true
                    self.previousHintsTableView.isHidden = false
                    self.previousHintsTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: TextView Delegate
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Select a Pre-Canned Hint from Above, or Manually Type One...")
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Select a Pre-Canned Hint from Above, or Manually Type One..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == questionsTableView {
            return questions.count
        } else if tableView == precannedHintsTableView {
            return precannedHints.count
        } else if tableView == previousHintsTableView {
            return hints.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == questionsTableView {
            let cell = questionsTableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath)
            if let hintCell = cell as? ESCTableViewCell {
                hintCell.textView.text = questions[indexPath.row].questionString
            }
            return cell
        } else if tableView == precannedHintsTableView {
            let cell = precannedHintsTableView.dequeueReusableCell(withIdentifier: "precanCell", for: indexPath)
            if let hintCell = cell as? ESCTableViewCell {
                hintCell.textView.text = precannedHints[indexPath.row].precanString
            }
            return cell
        } else if tableView == previousHintsTableView {
            let cell = previousHintsTableView.dequeueReusableCell(withIdentifier: "hintCell", for: indexPath)
            if let hintCell = cell as? ESCTableViewCell {
                hintCell.textView.text = hints[indexPath.row].hintString
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == previousHintsTableView {
            if editingStyle == .delete {
                if let record = hints[indexPath.row].record() {
                    publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                print("Cloud Query Error - Delete Hint: \(error)")
                            }
                            self.hints.remove(at: indexPath.row)
                            self.previousHintsTableView.deleteRows(at: [indexPath], with: .fade)
                            self.previousHintsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

