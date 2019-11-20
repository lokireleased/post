//
//  PostTableViewController.swift
//  Post
//
//  Created by tyson ericksen on 11/18/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostTableViewController: UITableViewController {
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    let postController = PostController()

    override func viewDidLoad() {
        super.viewDidLoad()
       configureRefreshControl()
        
        postController.fetchPosts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        myScrollView.refreshControl?.addTarget(self, action: #selector(refreshControllPulled), for: .valueChanged)
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {

        presentNewPostAlert()
        
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "Add Post", message: "", preferredStyle: .alert)
        alertController.addTextField { (_) in }
        alertController.addTextField { (_) in }
        let saveAlert = UIAlertAction(title: "Save", style: .default, handler: nil)
        guard let userName = alertController.textFields?[0].text else { return }
        guard let text = alertController.textFields?[1].text else { return }
        postController.addNewPostWith(username: userName, text: text) { (result) in
            switch result {
            case .success(let post):
                post.username = userName
                post.text = text
            case .failure(let error):
                self.presentErrorAlert()
            }
        }
        
        let cancelAlert = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAlert)
        alertController.addAction(saveAlert)
        self.present(alertController, animated: true)
    }
    
    func presentErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Not enough information, please try again", preferredStyle: .alert)
        let cancelAlert = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(cancelAlert)
        self.present(alertController, animated: true)
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.postArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)

       let post = postController.postArray[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.username + " " + "\(post.timestamp)" 

        return cell
    }

    func configureRefreshControl() {
        myScrollView.refreshControl = UIRefreshControl()

    }
    
    @objc func refreshControllPulled() {
        postController.fetchPosts { (result) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}

//extension PostTableViewController {
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        postController.fetchPosts(reset: false) { (results) in
//            tableView.reloadData()
//        }
//    }
//}
