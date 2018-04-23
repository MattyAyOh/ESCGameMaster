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
    
    var currentRoom = "sepia"
    
    
    @IBAction func roomSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            currentRoom = "sepia"
        } else if sender.selectedSegmentIndex == 1 {
            currentRoom = "platinum"
        } else if sender.selectedSegmentIndex == 2 {
            currentRoom = "crimson"
        }
        fetchAllQuestions()
        fetchAllPrecans()
        fetchAllHints()
    }
    
    @IBOutlet weak var roomSegmentedControl: UISegmentedControl!
    @IBOutlet weak var hintsContainer: UIView!
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var precannedHintsTableView: UITableView!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var previousHintsTableView: UITableView!
    @IBOutlet weak var questionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var precannedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previousActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var previousHintsHideConstraint: NSLayoutConstraint!
    @IBOutlet weak var previousHintsShowConstraint: NSLayoutConstraint!
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
    
    @IBAction func questionClearPressed(_ sender: UIButton) {
        for question in questions {
            if let record = question.record() {
                publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Delete Question: \(error)")
                        }
                    }
                }
            }
        }
        questions.removeAll()
        questionsTableView.reloadData()
    }
    @IBAction func questionRefreshPressed(_ sender: UIButton) {
        fetchAllQuestions()
    }
    
    @IBAction func precanRefreshPressed(_ sender: UIButton) {
        fetchAllPrecans()
    }
    
    @IBAction func previousClearPressed(_ sender: UIButton) {
        for hint in hints {
            if let record = hint.record() {
                publicDB.delete(withRecordID: record.recordID) { (recordID, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            print("Cloud Query Error - Delete Hint: \(error)")
                        }
                    }
                }
            }
        }
        hints.removeAll()
        previousHintsTableView.reloadData()
    }
    
    @IBAction func previousRefreshPressed(_ sender: UIButton) {
        fetchAllHints()
    }
    
    @IBAction func previousHintsPressed(_ sender: Any) {
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            if self.previousHintsShowConstraint.isActive {
                self.previousHintsShowConstraint.isActive = false
                self.previousHintsHideConstraint.isActive = true
                UserDefaults().set(false, forKey: "showPreviousHints")
            } else {
                self.previousHintsShowConstraint.isActive = true
                self.previousHintsHideConstraint.isActive = false
                UserDefaults().set(true, forKey: "showPreviousHints")
            }
            self.previousHintsTableView.layoutIfNeeded()
        }, completion: nil)

    }
    
    
    
    func fetchAllQuestions() {
        questionsTableView.isHidden = true
        questionsActivityIndicator.isHidden = false
        
        let predicate = NSPredicate(format: "room = %@", currentRoom)
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
        
        let predicate = NSPredicate(format: "room = %@", currentRoom)
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
        
        let predicate = NSPredicate(format: "room = %@", currentRoom)
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if UserDefaults().bool(forKey: "showPreviousHints") {
                            self.previousHintsShowConstraint.isActive = true
                            self.previousHintsHideConstraint.isActive = false
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendHintPressed(_ sender: Any) {
        let newHint:Hint = Hint()
        newHint.hintString = hintTextView.text
        newHint.room = currentRoom
        guard let record = newHint.record() else {
            return
        }
        publicDB.save(record) { (savedRecord, error) in
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Save Hint: \(error)")
                }
                return
            }
            print("Saved Successfully")
        }
        hintTextView.text = ""
        hintTextView.becomeFirstResponder()
        hintTextView.resignFirstResponder()
    }
    
    @IBAction func clearHintPressed(_ sender: Any) {
        hintTextView.text = ""
        hintTextView.becomeFirstResponder()
        hintTextView.resignFirstResponder()
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == precannedHintsTableView {
            hintTextView.textColor = .black
            hintTextView.text = precannedHints[indexPath.row].precanString
            tableView.deselectRow(at: indexPath, animated: false)
        }
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == precannedHintsTableView {
            return false
        }
        return true
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

