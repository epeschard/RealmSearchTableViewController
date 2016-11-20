//
//  CustomObject.swift
//  SearchRealmTableViewController
//
//  Created by Eugène Peschard on 19/11/2016.
//  Copyright © 2016 PeschApps. All rights reserved.
//

import RealmSwift

class CustomObject: Object {
    dynamic var name = ""
    dynamic var code = ""
    dynamic var image: NSData? = nil
}
