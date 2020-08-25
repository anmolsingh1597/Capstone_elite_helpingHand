//
//  FavTasksTableViewController.swift
//  Capstone_elite_helpingHand
//
//  Created by Anmol singh on 2020-08-21.
//  Copyright © 2020 Aman Kaur. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ToDoTasksTableViewController: UITableViewController {
    
//    var favTaskList: [FavoiteTasks] = []
    
    var db = Firestore.firestore()
    var taskStatusArray = [TaskStatus]()
    
    @IBOutlet weak var endTaskBtn: UIButton!
    @IBOutlet weak var startTaskBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        favTaskList = DataStorage.getInstance().getAllFavoriteTask()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadData()
        checkForUpdates()
    self.navigationItem.title = "To-Do Tasks"
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(doneBarButton))
        }

    @objc func doneBarButton(){
               self.dismiss(animated: true, completion: nil)
           }
    func loadData(){
        db.collection("taskStatus").whereField("userEmail", isEqualTo: Auth.auth().currentUser?.email ?? "No user").getDocuments() {
                  (querySnapshot, error) in
                  if let error = error {
                      print("\(error.localizedDescription)")
                  }else{
                    guard let queryCount = querySnapshot?.documents.count else { return }
                    if queryCount == 0{
                        self.displayAlert(title: "Hurray🎊", message: "All tasks are sorted. You have no in due tasks", flag: 0)

                    }else if queryCount >= 1{
                    for doc in querySnapshot!.documents{

                        let taskStatus = TaskStatus(dictionary: doc.data())
                        self.taskStatusArray.append(taskStatus)
                        }
                    }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                      }
                  }
              }
    }
    
    func checkForUpdates(){
        
        db.collection("taskStatus").whereField("userEmail", isEqualTo: Auth.auth().currentUser?.email ?? "No user").whereField("timeStamp", isLessThan: Date())
                 .addSnapshotListener {
                     querySnapshot, error in
                     
                     guard let snapshot = querySnapshot else {return}
                     
                     snapshot.documentChanges.forEach {
                         diff in
                         
                         if diff.type == .added {
                             self.taskStatusArray.append(TaskStatus(dictionary: diff.document.data()))
                             DispatchQueue.main.async {
                                 self.tableView.reloadData()
                             }
                         }
                     }
                     
             }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskStatusArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favTaskCell", for: indexPath) as! ToDoTaskTableViewCell

        let taskStatus = self.taskStatusArray[indexPath.row]
        // Configure the cell...
//        cell.textLabel?.text = "\(taskStatus.taskName), \(taskStatus.taskEmail) "
//        cell.detailTextLabel?.text = "\(taskStatus.timeStamp)"
        if(taskStatus.status == "inProgress"){
            cell.btnTaskStart.isEnabled = true
            cell.btnTaskDone.isEnabled = false
        }else if (taskStatus.status == "started"){
            cell.btnTaskStart.isEnabled = false
            cell.btnTaskDone.isEnabled = true
        }else if(taskStatus.status == "done"){
            cell.btnTaskStart.isEnabled = false
            cell.btnTaskDone.isEnabled = false
        }
        cell.taskTitle.text = taskStatus.taskName
        cell.taskEmail.text = taskStatus.taskEmail
        cell.toDoTaskCellDelegate =  self
//        let taskDate = taskStatus.timeStamp
//        let todayDate = Date()
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let taskDate = dateFormatter.date(from: taskStatus.timeStamp)!
//
//        let calendar = Calendar.current
//        let currentDate = calendar.startOfDay(for: todayDate)
//        let assignedDate = calendar.startOfDay(for: taskDate)
//
//        let components = calendar.dateComponents([.day], from: currentDate, to: assignedDate)
//
//        cell.daysLeft.text = "\(components.day)"
        

        return cell
    }

    func displayAlert(title: String, message: String, flag: Int){
          let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
          self.present(alert, animated: true)
      }
    func updateTaskStatusInFireStore(taskStatus: TaskStatus, flag: Int) {
        if flag == 0{

            self.db.collection("taskStatus").whereField("userEmail", isEqualTo: Auth.auth().currentUser?.email ?? "No user").whereField("taskEmail", isEqualTo: taskStatus.taskEmail).whereField("taskDueDate", isEqualTo: taskStatus.taskDueDate).whereField("taskName", isEqualTo: taskStatus.taskName).whereField("taskId", isEqualTo: taskStatus.taskId).limit(to: 1).getDocuments() { (querySnapshot, err) in
                   if let err = err {
                     self.displayAlert(title: "Error!", message: "\(err.localizedDescription)", flag: 0)
                    print("Error getting documents: \(err)")
                   } else {
                       for document in querySnapshot!.documents {
                        document.reference.updateData([
                            "status": "started"
                        ])
                       }
        }
    }
        }else if flag == 1{
            
    self.db.collection("taskStatus").whereField("userEmail", isEqualTo: Auth.auth().currentUser?.email ?? "No user").whereField("taskEmail", isEqualTo: taskStatus.taskEmail).whereField("taskDueDate", isEqualTo: taskStatus.taskDueDate).whereField("taskName", isEqualTo: taskStatus.taskName).whereField("taskId", isEqualTo: taskStatus.taskId).limit(to: 1).getDocuments() { (querySnapshot, err) in
                           if let err = err {
                            self.displayAlert(title: "Error!", message: "\(err.localizedDescription)", flag: 0)
                               print("Error getting documents: \(err)")
                           } else {
                               for document in querySnapshot!.documents {
                                document.reference.updateData([
                                    "status": "done"
                                ])
                               }
                }
            }
            
        }
    }
    
    }

extension ToDoTasksTableViewController: ToDoTaskTableViewCellDelegate{
    func toDoCell(cell: ToDoTaskTableViewCell, didTappedThe button: UIButton?) {
        if button == cell.btnTaskStart{
            guard let indexPath = tableView.indexPath(for: cell) else  { return }
            let taskStatus = self.taskStatusArray[indexPath.row]
            self.updateTaskStatusInFireStore(taskStatus: taskStatus, flag: 0)
            cell.btnTaskStart.isEnabled = false
            cell.btnTaskDone.isEnabled = true
            
        }else if button == cell.btnTaskDone{
            guard let indexPath = tableView.indexPath(for: cell) else  { return }
            let taskStatus = self.taskStatusArray[indexPath.row]
            self.updateTaskStatusInFireStore(taskStatus: taskStatus, flag: 1)
            cell.btnTaskStart.isEnabled = false
            cell.btnTaskDone.isEnabled = false
        }
       
    }
    
    
}