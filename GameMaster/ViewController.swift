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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    let publicDB = CKContainer.init(identifier: "iCloud.esc.GameMaster").publicCloudDatabase
    
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var precannedHintsTableView: UITableView!
    @IBOutlet weak var hintTextView: UITextView!
    @IBOutlet weak var previousHintsTableView: UITableView!
    @IBOutlet weak var questionsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var precannedActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var previousActivityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        fetchAllHints()
        let tables = [questionsTableView, precannedHintsTableView, previousHintsTableView]
        for table in tables {
            table?.tableFooterView = UIView()
            table?.layer.cornerRadius = 10
            table?.layer.masksToBounds = true
        }

        
        hintTextView.layer.cornerRadius = 10
        hintTextView.layer.masksToBounds = true
        hintTextView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
}

