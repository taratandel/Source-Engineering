//
//  packagesinfoTableViewController.swift
//  Managers
//
//  Created by Tara Tandel on 4/15/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class packagesinfoTableViewController: UITableViewController {
    
    
    var packagesInfos: [NSDictionary] = []
    var nationalCode: [NSManagedObject] = []
    var nationalNumber: String = ""
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchingdatafromCoreData()
        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return packagesInfos.count - 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "booksCell", for: indexPath)
        
        cell.detailTextLabel?.text = packagesInfos[indexPath.row + 1]["BookName"] as? String
        cell.textLabel?.text = "\(packagesInfos[indexPath.row + 1]["Price"] as! Int)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let bookid: Int = packagesInfos[indexPath.row + 1]["BookId"] as? Int{
                let packageid: Int = (packagesInfos[indexPath.row + 1]["PackageId"] as? Int)!
                let url = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/UpdateBookPackage?PackageMasterId=\(packageid)&BookId=\(bookid)"
                deleteFavorites(urls: url){
                    answer, error in
                    let deleteStatus = answer!
                    if deleteStatus == 1{
                        self.packagesInfos.remove(at: (indexPath.row + 1))
                        tableView.reloadData()
                    }
                }
            }
        }
    }
        func fetchingdatafromCoreData(){
            //preparing coredata
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //fetching Datas
            
            let fechtRequest  = NSFetchRequest<NSManagedObject>(entityName: "IsLoggedIn")
            
            //check if data exists or not
            do {
                //if exists fill the array
                nationalCode = try managedContext.fetch(fechtRequest)
                nationalNumber = nationalCode[0].value(forKey: "groupCode") as! String
            }
            catch let error as NSError {
                //if not shows the error
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
        }
    func deleteFavorites(urls: String, completionHandler: @escaping (Int?, Error?) ->()){
      let urlstr = urls
        Alamofire.request(urlstr).responseJSON{
            response in
            switch response.result{
            case .success(let value):
                completionHandler(value as? Int, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
    
}
