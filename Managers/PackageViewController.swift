//
//  PackageViewController.swift
//  Managers
//
//  Created by Tara Tandel on 4/4/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

class PackageTableViewCell : UITableViewCell{
    
    @IBOutlet weak var numberOfBooks: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var packageCode: UILabel!
}
class PackageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var packegeTAble: UITableView!
    @IBOutlet weak var roundedLayer: UILabel!
    @IBOutlet weak var packageBackground: UIImageView!
 
    var packagesInfo: [[NSDictionary]] = []
    var nationalCode: [NSManagedObject] = []
    var nationalNumber: String = ""
    var selectedrow: Int = 0
    var isTheFirstTimeLoading : Int = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.isHidden = false

    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = true


        super.viewWillAppear(true)
        if isTheFirstTimeLoading == 2 {
        packagesInfo = []
    
        self.viewDidLoad()
        packegeTAble.reloadData()
        }
        isTheFirstTimeLoading = 2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false

        makeRoundedLayer()
        fetchingdatafromCoreData()
        
        packageBackground?.image = #imageLiteral(resourceName: "packageBackGround")
        
        //makeRoundedLayer()
        
        gettingpackages()
        
        isTheFirstTimeLoading = 1
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //////////////////////////////////setting TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packagesInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "packageCell", for: indexPath) as! PackageTableViewCell
        
        let packageinfos = packagesInfo[indexPath.row]
        cell.numberOfBooks?.text = "\(packageinfos.count - 1)"
        var totalAmount = Int()
        var nameOfThePackage =  String()
        for i in 1..<packageinfos.count{
            if packageinfos[i].count>0{
            let bookinfo = packageinfos[i]
            totalAmount = totalAmount + (bookinfo["Price"] as! Int)
            nameOfThePackage = bookinfo["PackageName"] as! String
        }
        }
        cell.price?.text = "ریال \(totalAmount)"
        cell.packageCode?.text = "\(nameOfThePackage)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedrow = indexPath.row
        performSegue(withIdentifier: "deletefavorites", sender: self)
    }
    
    /////////////////////////////////setting initials
    func makeRoundedLayer(){
        roundedLayer.fullyRound(diameter: 20, borderColor: .lightGray, borderWidth: 3)
        roundedLayer.backgroundColor = .white
        packegeTAble.fullyRound(diameter: 20, borderColor: .lightGray, borderWidth: 3)
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
    func gettingpackages(){
        let urlstr = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/GetIosPackage?NationalCode=\(nationalNumber)"
        Alamofire.request(urlstr).responseJSON{
            response in
            switch response.result{
            case .success(let value):
                
                let result = value as! NSArray
                for i in 0..<result.count{
                    let resultpackage = result[i] as! NSArray
                    self.packagesInfo.append([NSDictionary()])
                    for j in 0..<resultpackage.count{
                        let resultbook = resultpackage[j] as! NSDictionary
                        self.packagesInfo[i].append(resultbook)
                        DispatchQueue.main.async(execute: {
                            
                            self.packegeTAble.reloadData()
                        })
                       // print(self.packagesInfo)
                    }
                }
            case .failure(let error):
                print (error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deletefavorites" {
            let packageTable = segue.destination as! packagesinfoTableViewController
            packageTable.packagesInfos = packagesInfo[selectedrow]
        
        }
    }
}
