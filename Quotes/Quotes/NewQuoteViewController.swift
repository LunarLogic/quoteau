//
//  NewQuoteViewController.swift
//  Quotes
//
//  Created by Wiktor Górka on 05/12/2019.
//  Copyright © 2019 Lunar Logic. All rights reserved.
//

import UIKit

class NewQuoteViewController: UITableViewController {

    var quoteText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "headerId")
        tableView.backgroundColor = .systemGray6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = quoteText ?? ""
        default:
            break
        }
      return cell
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId")
        
        switch section {
        case 0:
            header?.textLabel?.text = "Quote"
        case 1:
            header?.textLabel?.text = "Name"
        default:
            break
        }
        return header
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
