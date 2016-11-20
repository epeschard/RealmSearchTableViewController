//
//  RealmDetailTableViewController.swift
//  SearchRealmTableViewController
//
//  Created by Eugène Peschard on 19/11/2016.
//  Copyright © 2016 PeschApps. All rights reserved.
//

import UIKit
import RealmSwift

class RealmDetailViewController: UIViewController {
    
    typealias Entity = CustomObject
    var object: Entity?
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        navigationItem.title = object?.name ?? "N/A"
        
        nameLabel.text = object?.name ?? "N/A"
        codeLabel.text = object?.code ?? "N/A"
        if let imageData: NSData = object?.image as? NSData {
            imageView.image = UIImage(data: imageData)
        }
    }
}
