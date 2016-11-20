//
//  ResultsTableViewController.swift
//  SearchRealmTableViewController
//
//  Created by Eugène Peschard on 19/11/2016.
//  Copyright © 2016 PeschApps. All rights reserved.
//

import UIKit
import RealmSwift

class RealmResultTableViewController: UITableViewController {
    
    typealias Entity = CustomObject
    typealias TableCell = CustomTableViewCell
    
    let textForEmptyLabel = "No results matching search"
    
    // MARK: - Instance Variables
    var searchString = ""
    var searchResults = try! Realm().objects(Entity) {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return searchResults.count
        let rowCount = searchResults.count
        
        // When no data insert centered label
        if rowCount == 0 {
            handleEmptyTable()
        } else {
            // Remove empty table label
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        }
        
        return rowCount
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
            let cell: TableCell =
                tableView.dequeueReusableCellWithIdentifier("\(TableCell.self)", forIndexPath: indexPath) as! TableCell
            
            cell.searchString = searchString
            cell.object = searchResults[indexPath.row]
            
            return cell
    }
    
    func handleEmptyTable() {
        //create a lable size to fit the Table View
        let messageLbl = UILabel(frame: CGRectMake(0, 0,
                                                   tableView.bounds.size.width,
                                                   tableView.bounds.size.height))
        
        //set the message
        messageLbl.text = textForEmptyLabel
        
//        messageLbl.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        messageLbl.font = UIFont.systemFontOfSize(19)
        messageLbl.textColor = UIColor.grayColor()
        
        // Attributed Text
//        messageLbl.attributedText =
        
        //center the text
        messageLbl.textAlignment = .Center
        //multiple lines
        messageLbl.numberOfLines = 0
        
        //auto size the text
        messageLbl.sizeToFit()
        
        //set back to label view
        tableView.backgroundView = messageLbl
        
        //no separator
        tableView.separatorStyle = .None
    }
    
}
