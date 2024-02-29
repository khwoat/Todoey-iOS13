//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var items: Results<Item>?
    
    var selectedCate: Category? {
        didSet {
            loadItems()
        }
    }
    
    /// Use Codable
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    /// Context of Persistent Container from CoreData
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedCate?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let cateColor = selectedCate?.colorString {
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller is not exits.") }
            
            navBar.backgroundColor = UIColor(hexString: cateColor)
            
            if let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: cateColor), isFlat: true) {
                navBar.tintColor = contrastColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: contrastColor]
            }
            
            searchBar.tintColor = UIColor.white
            searchBar.barTintColor = UIColor(hexString: cateColor)
        }
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added Yet"
        }
        
        // Set Color
        if let cateColor = UIColor(hexString: selectedCate?.colorString) {
            if let bgColor = cateColor.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                cell.backgroundColor = bgColor
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: bgColor, isFlat: true)
            }
        }
        
        
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Write Failed: \(error)")
            }
        }
        
        self.tableView.reloadData()
        
        // Delete Item
//        context.delete(item)
//        items.remove(at: indexPath.row)
        
        // When deleted item, still need to call context.save() to update table
//        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Item Method
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            /// Save data with Realm
            if let currentCategory = self.selectedCate {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Save Item Failed: \(error)")
                }
            }
            
            self.tableView.reloadData()
            
            /// Save with CoreData
//            let newItem = Item(context: self.context)
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.parentCategory = self.selectedCate!
//            
//            self.items.append(newItem)
//            
//            self.saveItems()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Todoey"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
        
    }
    
    /// Load data with Realm
    func loadItems() {
        items = selectedCate?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                self.realm.delete(self.items![indexPath.row])
            }
        } catch {
            print("Delete Category Failed: \(error)")
        }
    }
    
    /// Save and Load with CoreData
//    func saveItems() {
//        do {
//            try context.save()
//        } catch {
//            print("Save Data to CoreData Failed. \(error)")
//        }
//        self.tableView.reloadData()
//    }
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//        let catePredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCate!.name!)
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [catePredicate, additionalPredicate])
//        } else {
//            request.predicate = catePredicate
//        }
//        do {
//            items = try context.fetch(request)
//        } catch {
//            print("Read Data from CoreData Failed. \(error)")
//        }
//        self.tableView.reloadData()
//    }
}

//MARK: - Search Bar Methods

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        /// Filter by Realm
        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        /// Filter with CoreData
//        let request: NSFetchRequest<Item> = Item.fetchRequest()
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//        request.sortDescriptors?.append(NSSortDescriptor(key: "title", ascending: true))
//        loadItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


