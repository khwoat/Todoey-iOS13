//
//  Category.swift
//  Todoey
//
//  Created by IT-HW05011-00224 on 27/2/2567 BE.
//  Copyright © 2567 BE App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorString: String = ""
    let items = List<Item>()
}
