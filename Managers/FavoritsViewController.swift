//
//  FavoritsViewController.swift
//  Managers
//
//  Created by Tara Tandel on 4/3/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import SwiftyJSON

class FavoritsViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var ToltalAmount: UILabel!
    @IBOutlet weak var packagealert: UILabel!
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var nameOfThePackage: UITextField!
    @IBOutlet weak var BackGround: UIImageView!
    
    var lastSelectedIndexPath = [Int]()
    var nationalCode: [NSManagedObject] = []
    var nationalNumber: String = ""
    var packageInfo = [[String : Any?]]()
    var bookid:[Int] = []
    var prices: [Int] = []
    var booksname: [String] = []
    var isTheFirstTimeLoading = true

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        super.viewWillAppear(true)
        if !isTheFirstTimeLoading {
            self.viewDidLoad()
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false

        self.hideKeyboardWhenTappedAround()
        nameOfThePackage.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        fetchingdatafromCoreData()
        calculatingtotalamount()
        favoritesTableView.fullyRound(diameter: 20, borderColor: .lightGray, borderWidth: 3)
        let urlst = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/GetIosFavorite?NationalCode=\(nationalNumber)"
        getFavorites(urls: urlst){
            books, idcount, prices , error in
            if idcount != nil {
            self.bookid = idcount as! [Int]
            self.prices = prices as! [Int]
            self.booksname = books as! [String]
            self.favoritesTableView.reloadData()
            }
            else {
                print ("not internet")
            }
        }
        favoritesTableView.allowsMultipleSelection = true
        BackGround?.image = #imageLiteral(resourceName: "favorites")
        isTheFirstTimeLoading = false
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func MakingPackage(_ sender: Any) {
        makingPackageArray()
        do {
            let data = try JSONSerialization.data(withJSONObject: packageInfo, options: .prettyPrinted)
            let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            let urlEncodedJson = jsonString!.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let urlString = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/InsertIosPackage?PackageInfo=\(urlEncodedJson!)"
            Alamofire.request(urlString).responseJSON{
                response in
                switch response.result{
                case .success (let value):
                    if let result: NSDictionary = value as? NSDictionary{
                        if let res: String = result["errorMsg"] as? String{
                            if res == "Insert Successfull"{
                                self.packagealert.text = "ثبت شد"
                            
                            }
                        }
                        
                    }
                case .failure(let error):
                    self.packagealert?.text = "ثبت با مشکل روبرو شده است لطفا دوباره تلاش کنید"
                    
                    // Trigger alaomofire request with url
                }
            }
            
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        packagealert?.text = ""
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookid.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "favoritecells", for: indexPath)
        if (lastSelectedIndexPath.contains(indexPath.row)){
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        else {
            cell.accessoryType = .none
        }
        cell.backgroundColor = .clear
        cell.textLabel?.text = "\(prices[indexPath.row]) ریال"
        cell.detailTextLabel?.text = "\(booksname[indexPath.row]) "
        return cell
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            cell.accessoryType = .none
            if let index = lastSelectedIndexPath.index(of: indexPath.row) {
                lastSelectedIndexPath.remove(at: index)
            }        }
        calculatingtotalamount()
        if lastSelectedIndexPath.count == 0 {
            ToltalAmount?.text = "کتابی انتخاب نشده است"
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let BookId = bookid[indexPath.row]
            let url = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/UpdateBookFavorite?NationalCode=\(nationalNumber)&BookId=\(BookId)"
            requesttodelet(urls: url){
                answer, error in
                let deleteStatus = answer!
                if deleteStatus == 1{
                    self.bookid.remove(at: indexPath.row)
                    self.prices.remove(at: indexPath.row)
                    self.booksname.remove(at: indexPath.row)

                     let isIndexValid = self.lastSelectedIndexPath.indices.contains(indexPath.row)
                    if isIndexValid{
                        self.lastSelectedIndexPath.remove(at: indexPath.row)
                    }
                    self.calculatingtotalamount()
                    tableView.deleteRows(at: [indexPath], with: .fade)

                }
                
            }
            
        } else if editingStyle == .insert {
            performSegue(withIdentifier: "backToChangeTheBasket", sender: self)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            lastSelectedIndexPath.append(indexPath.row)
            
        }
        calculatingtotalamount()
    }
    
    
    func getFavorites(urls: String, completionHandler: @escaping (NSArray?, NSArray?, NSArray? , Error?) -> ()){
        
        let urlstr = urls
        var idcount: [Int] = []
        var booksnames = [String]()
        var pricess: [Int] = []
        Alamofire.request(urlstr).responseJSON{
            response in
            
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let jArray = json.array{
                    for books in jArray{
                        if let Bookname = books["BookName"].string{
                            if let bookid = books["BookId"].int{
                                if let prices = books["Price"].int{
                                    idcount.append(bookid)
                                    booksnames.append(Bookname)
                                    pricess.append(prices)
                                    completionHandler(booksnames as NSArray ,idcount as NSArray, pricess as NSArray, nil)
                                }
                            }
                        }
                        
                    }
                    
                }
            case .failure(let error):
                completionHandler(nil,nil,nil, error)
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
    func makingPackageArray(){
        if (nameOfThePackage.text != "") && (lastSelectedIndexPath.count > 0) {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let result = formatter.string(from: date)
            for indexes in lastSelectedIndexPath {
                packageInfo.append(["PackageName": "\(nameOfThePackage.text!)",
                    "NationalCode": "\(nationalNumber)",
                    "BookId": bookid[indexes] ,
                    "CreateDate": "\(result)"])
            }
        }
        else {
            packagealert?.text = "لطفا نام پکیج را وارد کنید"
        }
    }
    func calculatingtotalamount(){
        var totalamount :Int = 0
        for indexes in lastSelectedIndexPath {
            if let amountOfEachBook: Int = prices[indexes] as? Int{
                    totalamount = totalamount + amountOfEachBook
                    if totalamount != 0{
                        ToltalAmount?.text = "\(totalamount)ریال "
                        
                    }
                    else {
                        ToltalAmount?.text = "کتابی وجود ندارد"
                    }
                
                
            }
        }
    }
    func requesttodelet (urls: String, completionHandler: @escaping (Int?, Error?) ->()){
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
