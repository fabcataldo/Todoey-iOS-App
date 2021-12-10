//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
//    let defaults = UserDefaults.standard
    
//    this code is used for Codeable protocol-plist storage mode
    //Dejo de usar el modo de guardado de datos con NSUserDefaults,
    // y genero un modo de guardado utilizando un .plist
    //la variable de abajo me consigue la url dentro del disp en donde se van a guardar las tareas que guarde el usuario
    
    //constante donde primero ubico el directorio Documents, y el parametro in: ubico el directorio home del user, en deonde vamos a guardar los items asociados personales de esta app
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
//-----------------------------------------
    
    @IBOutlet var searchBar: UITableView!
    //    CoreData storage mode
//    we rescue the context so we can use it when we need it, to use CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        var newItem = Item()
//        newItem.title = "Find Mike"
//        itemArray.append(newItem)
//        
//        var newItem2 = Item()
//        newItem2.title = "Buy eggs"
//        itemArray.append(newItem2)
        
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }

//        this code is used for Codeable protocol-plist storage mode
        //        loadItems()
        
        
//        searchBar.delegate = self
//        loadItems()
    }
    
    //Tableview Datasource methods
    
    //this is a method that gives to the table the number of rows that the tableview has to print
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //this is a method that configures the tableview's celds
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //this variable is an instance of the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListItemCell", for: indexPath)
        
        //lleno la celda teniendo en cuenta la row actual,
        //y pasandola como indice al itemArray, que dicho array
        //tiene la info de cada celda
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        //devuelvo la celda que construi, para que se pegue en la tabla
        return cell
    }
    
    //MARK - TableView Delegate Methods
    //tableView tells the delegate (this class) that one row is now selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
//        If I want to delete data in the database, first I have to pass to the context the Item that I want to remove
//        context.delete(itemArray[indexPath.row])
//        then, I remove the item from the itemArray
//        itemArray.remove(at: indexPath.row)
//        and them I update the context of the persistent container calling the saveItems() method
        
        saveItems()
//        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK add new items section
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            //what will happen once the user clicks the add item button on our UIAlert

            // Codeable protocol-plist storage mode
//            var newItem = Item()
            
            
//            Now, with CoreData, below we need the viewContext
//            so we use the UIApplication class, in which we rescue the "shared" singleton object, which is the object representing the app running in the iPhone, and then the .delegate (its own delegate, whhich type is UIApplicationDelegate, then its casted to AppDelegate, because they both inherit from the same superclass UIApplicationDelegate) is the AppDelegate, we obtain finally the object that we need
//newItem is a variable that is a NSManagedObject, a new row in the SQLite database that I have created before using Core Data
            var newItem = Item(context: self.context)
            
            newItem.title = textField.text ?? "new Item"
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.saveItems()
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(){
        
        // Codeable protocol-plist storage mode
        //la variable encoder es un objeto que permite codificar un objeto de tipo Encodable, y el modelo Item del itemArray adhiere al protocolo Encodable
//        let encoder = PropertyListEncoder()
//        do{
//            //en la variable data obtengo el arreglo codificado
//
//            // Codeable protocol-plist storage mode
//            //  let data = try encoder.encode(itemArray)
//
//            //como esta sujeto a errores, agrego try a la llamada al metodo write de la variable data de arriba, y guarda los datos en la direccion identificada por dataFilePath
//            try data.write(to: dataFilePath!)
//        } catch{
//            print("Error encoding item array, \(error)")
//        }
        do{
//            Here I use the context that I need to access to the database, to save the uncommit changes in the PersistentStore (lazy variable in AppDelegate, which is the database itself)
            try context.save()
        }catch{
           print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
  
//    This is used for Codeable protocol-plist storage mode
//    func loadItems(){
//        if let data = try? Data(contentsOf: dataFilePath!){
//            let decoder = PropertyListDecoder()
//            do{
//                itemArray = try decoder.decode([Item].self, from: data)
//            } catch{
//                print("Error decoding item array, \(error)")
//            }
//
//        }
//    }
//    func loadItems(request: NSFetchRequest<Item>){


//    the "with" word tells the function that uses the external parameter that could be sent from outside
//    if from outside the method does not receive the request parameter, the parameter that is used is the internal... "request", with the default value that is set after the =
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        // the variable request, pulls all of the rows of the database, of the entity (or the table) Item
//        let request:NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else{
            request.predicate = categoryPredicate
        }
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
//        request.predicate = compoundPredicate
        
        do{
            // here I use the context interface to make the request and fetch data
            itemArray = try context.fetch(request)
            
            tableView.reloadData()
        }catch{
            print("Error fetching data from context \(error)")
        }
        
    }
    
}

//with extend I "extend" the TodoListViewController functionality to have code related to the delegate associated with the controller
//advantages: modularization and splitting up of related functionalities in the controller
extension TodoListViewController: UISearchBarDelegate{
    //    function that tells the delegate that the search button was tapped, and here the table view has to be reloaded using the text that the user inputted in the search bar
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            
            let predicate  = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
            
//            loadItems(request: request)
            loadItems(with: request, predicate: predicate)
        }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
//            Putting back to the main thread, of the n threads that were deployed in the system for this app, the task of remove the search bar current cursor and remove the keyboard from the screen
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
