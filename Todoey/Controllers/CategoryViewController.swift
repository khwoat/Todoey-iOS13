//
//  CategoryViewController.swift
//  Todoey
//
//  Created by IT-HW05011-00224 on 22/2/2567 BE.
//  Copyright © 2567 BE App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    // CoreData context
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation Controller is not exits.") }
        
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            let color = UIColor(hexString: category.colorString)
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        } else {
            cell.textLabel?.text = "No Categories Added Yet"
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destVC.selectedCate = categories?[indexPath.row]
        }
    }
    
    //MARK: - Add Category

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { action in
            let newCate = Category()
            newCate.name = textField.text!
            newCate.colorString = UIColor.randomFlat().hexValue()
            
            self.saveCategory(category: newCate)
        }

        alert.addTextField { alertTextfield in
            alertTextfield.placeholder = "New Category Name"
            textField = alertTextfield
        }
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    //MARK: - Data Manipulate Methods
    
    // Save with Realm
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Save Category Failed: \(error)")
        }
        tableView.reloadData()
    }
    
    // Load with Realm
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    /// Save and load with CoreData
//    func saveCategories() {
//        do {
//            try context.save()
//        } catch {
//            print("Save Categories Failed: \(error)")
//        }
//        self.tableView.reloadData()
//    }
//    func loadCategories() {
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//        do {
//            categories = try context.fetch(request)
//            print("Load Categories Success")
//        } catch {
//            print("Load Categories Failed: \(error)")
//        }
//        self.tableView.reloadData()
//    }
    
    //MARK: - Data Deletion Method
    
    override func updateModel(at indexPath: IndexPath) {
        do {
            try self.realm.write {
                self.realm.delete(self.categories![indexPath.row])
            }
        } catch {
            print("Delete Category Failed: \(error)")
        }
    }
}
