//
//  CustomTableViewCell.swift
//  SearchRealmTableViewController
//
//  Created by Eugène Peschard on 19/11/2016.
//  Copyright © 2016 PeschApps. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    var object: CustomObject? {
        didSet {
            updateUI()
            setFonts()
        }
    }
    
    func setFonts() {
        textLabel!.font = customBody
    }
    
    func updateUI() {
        if searchString != "" {
            textLabel?.textColor = UIColor.grayColor()
        }
        textLabel?.attributedText = highlight(searchString, inString: object?.name ?? "N/A")
        if let imageData = object?.image {
            imageView?.image = UIImage(data: imageData)
        }
    }
    
    // This part bellow may be extracted and then subclassed
    var searchString = ""
    
    // Custom Dynamic Text Fonts
    let customHeadline = UIFont(descriptor: UIFontDescriptor.preferredCustomFontWithDescriptor(UIFontTextStyleHeadline), size: 0)
    let customSubheadline = UIFont(descriptor: UIFontDescriptor.preferredCustomFontWithDescriptor(UIFontTextStyleSubheadline), size: 0)
    let customBody = UIFont(descriptor: UIFontDescriptor.preferredCustomFontWithDescriptor(UIFontTextStyleBody), size: 0)
    
    var attributes : [String: AnyObject] {
        get {
//            let shadow = NSShadow()
//                shadow.shadowBlurRadius = 1.0
//                shadow.shadowColor = UIColor.blueColor()
//                shadow.shadowOffset = CGSizeMake(0, 1.0)
            return [NSForegroundColorAttributeName : UIColor.blueColor()
//                NSUnderlineStyleAttributeName: 1,
//                NSShadowAttributeName: shadow,
//                NSFontAttributeName: customHeadline
            ]
        }
    }
    
    // MARK: - Highlight search
    
    func highlight(subString:String,
                   inString string:String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string)
        if subString != "" {
            
            let searchStrings = subString.componentsSeparatedByString(" ") as [String]
            for searchString in searchStrings {
                
                let swiftRange = string.rangeOfString(searchString,
                                                      options: .CaseInsensitiveSearch,
                                                      range: nil,
                                                      locale: NSLocale.currentLocale())
                if let swiftRange = swiftRange {
                    let nsRange = string.getNSRangeFrom(swiftRange)
                    attributedString.setAttributes(attributes, range: nsRange)
                }
                
            }
        }
        
        return attributedString
    }
}
