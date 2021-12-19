//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Чистяков Василий Александрович on 18.12.2021.
//

import UIKit
import Firebase

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var user: Users!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    @IBOutlet weak var tabelView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentUser = Auth.auth().currentUser else { return }
        user = Users(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tabelView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .clear
        
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        cell.textLabel?.textColor  = .darkGray
        
        cell.textLabel?.text = taskTitle
        toggleComplition(cell, isComplited: isCompleted)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tabelView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isComplited = !task.completed
        
        toggleComplition(cell, isComplited: isComplited)
        task.ref?.updateChildValues(["completed": isComplited])
    }
    
    func toggleComplition(_ cell: UITableViewCell, isComplited: Bool) {
        cell.accessoryType = isComplited ? .checkmark : .none
    }
    
    @IBAction func addTapped(_ sender: Any) {
        let ac = UIAlertController(title: "New tasks ", message: "Add tasks", preferredStyle: .alert)
        let save = UIAlertAction(title: "Ok", style: .default) {[weak self] alert in
            guard let tf = ac.textFields?.first, tf.text != "" else { return }
            let task = Task(title: tf.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(task.convertToDictionary())
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        ac.addAction(save)
        ac.addAction(cancel)
        ac.addTextField { _ in}
        
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        do {
            try  Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
