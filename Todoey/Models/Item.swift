//
//  Item.swift
//  Todoey
//
//  Created by IT-HW05011-00224 on 27/2/2567 BE.
//  Copyright © 2567 BE App Brewery. All rights reserv ed.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
