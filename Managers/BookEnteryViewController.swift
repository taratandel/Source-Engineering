//
//  BookEnteryViewController.swift
//  Managers
//
//  Created by Tara Tandel on 3/31/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class BookEnteryViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    
    
    @IBOutlet weak var searchBook: UIButton!
    @IBOutlet weak var Starbutt: UIButton!
    
    
    @IBOutlet weak var Warning: UILabel!
    @IBOutlet weak var TotalAmount: UILabel!
    @IBOutlet weak var NameOfThebookAfter: UILabel!
    
    
    @IBOutlet weak var packageCodeEmter: UITextField!
    @IBOutlet weak var bookCodeEnter: UITextField!
    @IBOutlet weak var nationalcodeenter: UITextField!
    
    
    @IBOutlet weak var background: UIImageView!
    
    
    var factorid = Int()
    var packagesInfo: [[NSDictionary]] = []
    var nationalCode: [NSManagedObject] = []
    var price = Int()
    var BookName = String()
    var factor: [Int : Dictionary<String, Any>] = [ : ]
    var nationalNumber: String = ""
    var isFavorite : Bool = false
    var totalpriceamount = [Int]()
    var isBacked: Bool = false
    var buttisEnable = false
    var desiredPackage : [NSDictionary] = []
    var packagePrice : [Int] = []
    var nameOfTheBooksInThePackages:[String] = []
    var isloggingout : Bool = false
    var wrongBookCode = String()
    var wrongPackageName = String()
    
    
    
    
    ///////////////////////////////////////////////setting the View before it apears
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if isloggingout {
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if isBacked == true {
            calculatingtotalamount()
            packageCodeEmter?.text = ""
            bookCodeEnter.text = ""
            Warning.text = ""
            isBacked = false
            if factor.count == 0{
                NameOfThebookAfter?.text = "هنوز کتابی جستجو نشده است"
                TotalAmount?.text = "هنوز کتابی انتخاب نشده است"
                Starbutt.setImage(UIImage(named: "trasparentstar.png"), for: .normal)
            }
        }
        if factorid != 0{
            Warning.text = "آخرین شماره فاکتور \(factorid)"
        }
        if factor.count == 0{
            nationalcodeenter.text = ""
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
        isBacked = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makingRoundBoundries()
        //self.navigationController?.navigationBar.isHidden = true
        //setting target action for text field to change the other one
        packageCodeEmter.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        
        bookCodeEnter.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        nationalcodeenter.addTarget(self, action: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)), for: UIControlEvents.editingDidBegin)
        //for setting limit on input
        nationalcodeenter.delegate = self
        
        background?.image = #imageLiteral(resourceName: "background")
        
        self.hideKeyboardWhenTappedAround()
        
        settingBordersForTextFields()
        
        fetchingdatafromCoreData()
        
        Starbutt.setImage(UIImage(named: "trasparentstar.png"), for: .normal)
        
        // getPackageInfo()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    ////////////////////////////////////////////////// setting the buttons functions
    
    @IBAction func logOut(_ sender: Any) {
        isloggingout = true
        performSegue(withIdentifier: "logout", sender: self)
        
    }
    
    @IBAction func searchBook(_ sender: Any) {
        wrongPackageName = ""
        wrongBookCode = ""
        if (bookCodeEnter.text?.characters.count)!>0 && (packageCodeEmter.text?.characters.count)! == 0{
            let BookCode : String = bookCodeEnter.text!
            self.gettingBookInfo(bookcode: BookCode){
                results, error in
                if results != nil {
                    if((results?["errorId"]) as! Int == 0){
                        self.Starbutt.setImage(UIImage(named: "trasparentstar.png"), for: .normal)
                        self.isFavorite = false
                        self.buttisEnable = true
                        self.price = results?["Price"] as! Int
                        self.BookName = results?["BookName"] as! String
                        self.NameOfThebookAfter.text = "\(self.BookName) \n \(self.price) ریال"
                        if((results?["IsFavorite"] as! Bool ) == true)
                        {
                            self.Starbutt.setImage(UIImage(named: "filledstar.png"), for: .normal)
                        }
                        
                    }
                    else {
                        
                        self.wrongBookCode = self.bookCodeEnter.text!
                        self.Warning?.text = "کد کتاب صحیح نیست"
                    }
                }
                else {
                    self.Warning?.text = "اینترت خود را بررسی کنید"
                }
                
            }
            
        }
        else if (bookCodeEnter.text?.characters.count)! == 0 && (packageCodeEmter.text?.characters.count)! > 0{
            let packagename = packageCodeEmter.text!
            desiredPackage = []
            packagesInfo = []
            getPackageInfo{
                results, error in
                if let result : NSArray = results{
                    for i in 0..<result.count{
                        let resultpackage = result[i] as! NSArray
                        self.packagesInfo.append([NSDictionary()])
                        for j in 0..<resultpackage.count{
                            let resultbook = resultpackage[j] as! NSDictionary
                            self.packagesInfo[i].append(resultbook)
                            self.viewWillAppear(true)
                            // print(self.packagesInfo)
                        }
                    }
                }
                
                if self.packagesInfo.count > 0{
                    for i in 0..<self.packagesInfo.count{
                        
                        for j in 1..<self.packagesInfo[i].count{
                            if packagename == self.packagesInfo[i][j]["PackageName"] as! String{
                                self.desiredPackage.append(self.packagesInfo[i][j])
                                
                            }
                        }
                        if self.desiredPackage.count>0 {
                            break
                        }
                    }
                }
                if self.desiredPackage.count == 0 {
                    self.wrongPackageName = self.packageCodeEmter.text!
                    self.Warning?.text = "نام پکیچ اشتباه است"
                }
                if self.desiredPackage.count > 0 {
                    self.calculatingtotalamount()
                }
            }
        }
        else if (bookCodeEnter.text?.characters.count)! == 0 && (packageCodeEmter.text?.characters.count)! == 0{
            self.Warning?.text = "لطفا همه مقادیر مورد نیاز را پر کنید"
            
        }
        else {
            self.Warning?.text = "لطفا فقط یکی از مقادیر پکیج و کتاب را وارد کنید"
            
        }
        
        
        
    }
    
    @IBAction func Farvorite(_ sender: Any) {
        if buttisEnable{
            isFavorite = !isFavorite
            if isFavorite == true {
                self.Starbutt.setImage(UIImage(named: "filledstar.png"), for: .normal)
            }
            else{
                self.Starbutt.setImage(UIImage(named: "trasparentstar.png"), for: .normal)
            }
        }
    }
    
    @IBAction func addBasket(_ sender: Any) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date)
        
        if factor.count > 11 {
            Warning?.text = "بیشتر از حد مجاز کتاب انتخاب شده است"
            
        }
        else{
            if ((bookCodeEnter.text?.characters.count)! > 0 || (packageCodeEmter.text?.characters.count)! > 0 ) && ((nationalcodeenter.text?.characters.count)! > 0)  {
                //filling factor for json Array
                
                if (bookCodeEnter.text?.characters.count)! > 0 && bookCodeEnter.text! != wrongBookCode {        if factor[Int(bookCodeEnter.text!)!] != nil{
                    Warning?.text = "مقدار کتاب تکراری است"
                    }
                    factor[Int(bookCodeEnter.text!)!] = ["bookId": Int(bookCodeEnter.text!)!,
                                                         "nationalCode": nationalNumber,
                                                         "price": price ,
                                                         "orderDate": "\(result)",
                        "mobileNo": nationalcodeenter.text!,
                        "isFavorite": isFavorite,
                        "bookName": BookName,]
                    
                    
                    
                }
                else if (packageCodeEmter.text?.characters.count)! > 0 && packageCodeEmter.text! != wrongPackageName{
                    for i in 0..<desiredPackage.count {
                        factor[(desiredPackage[i]["BookId"] as! Int)] = ["bookId": (desiredPackage[i]["BookId"] as! Int),
                                                                         "nationalCode": nationalNumber,
                                                                         "price": desiredPackage[i]["Price"] as! Int ,
                                                                         "orderDate": "\(result)",
                            "mobileNo": nationalcodeenter.text!,
                            "isFavorite": true ,
                            "bookName": desiredPackage[i]["BookName"] as! String,
                        ]
                    }
                }
                
                calculatingtotalamount()
                
                
            }
                
            else{
                Warning?.text = "لطفا ابتدا تمامی مقادیر مورد نیاز را پر کنید و س‍پس دکمه جستجو را فشار دهید"
            }
        }
        bookCodeEnter?.text = ""
        packageCodeEmter?.text = ""
        
    }
    
    @IBAction func ObserveAndorder(_ sender: Any) {
        if factor.count > 0 {
            performSegue(withIdentifier: "ObserveAndFinalOrder", sender: self)
        }
        else{
            Warning?.text = "لطفا سبد خرید را تکمیل کنید"
            
        }
    }
    
    
    //////////////////////////////////////other functions
    
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
            Warning?.text = "خطایی رخ داده لطفا برنامه را بسته و دوباره باز کنید"
        }
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        Warning?.text = ""
        if bookCodeEnter.isEditing {
            packageCodeEmter.backgroundColor = .gray
            bookCodeEnter.backgroundColor = .white
            packageCodeEmter?.text = ""
        }
        if packageCodeEmter.isEditing{
            packageCodeEmter.backgroundColor = .white
            bookCodeEnter.backgroundColor = .gray
            bookCodeEnter?.text = ""
        }
    }
    
    func settingBordersForTextFields(){
        
        nationalcodeenter.layer.borderWidth = 4
        nationalcodeenter.layer.borderColor = UIColor.gray.cgColor
        
        packageCodeEmter.layer.borderWidth = 4
        packageCodeEmter.layer.borderColor = UIColor.gray.cgColor
        
        
        bookCodeEnter.layer.borderWidth = 4
        bookCodeEnter.layer.borderColor = UIColor.gray.cgColor
        
        NameOfThebookAfter.layer.borderWidth = 4
        NameOfThebookAfter.layer.borderColor = UIColor.gray.cgColor
        
        TotalAmount.layer.borderWidth = 4
        TotalAmount.layer.borderColor = UIColor.gray.cgColor
        
        
        
    }
    
    
    func gettingBookInfo(bookcode: String, completionHandler: @escaping (NSDictionary?, Error?) -> ()){
        let codeOfBook  = bookcode
        let urlstring = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/GetBookInfo?BookId=\(codeOfBook)"
        Alamofire.request(urlstring).responseJSON{
            response in
            switch response.result{
            case .success (let value):
                if let result: NSDictionary = value as? NSDictionary{
                    completionHandler(result, nil)
                }
                else{
                    self.Warning?.text = "کد کتاب صحیح نیست"
                }
            case .failure(let error):
                self.Warning?.text = "لطفا اتصال اینترنت را بررسی کنید"
                completionHandler(nil, error)
            }
            
        }
    }
    
    //make the text field to get only 12 charachter
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text! + string)
        if str.characters.count <= 11 {
            return true
        }
        textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 11))
        return false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ObserveAndFinalOrder"{
            let nextViewC = segue.destination as! OrderListViewController
            nextViewC.factor = factor
            
        }
        if segue.identifier == "logout"{
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
                for managedObject in nationalCode
                {
                    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                    managedContext.delete(managedObjectData)
                }
            } catch let error as NSError {
                print("Detele all data in IsLoggedIn error : \(error) \(error.userInfo)")
            }
            let loginview = segue.destination as! ViewController
            loginview.hidesBottomBarWhenPushed = true
        }
    }
    func calculatingtotalamount(){
        
        if factor.count>0{
            var totalamount :Int = 0
            for (kies, _) in factor {
                if let amountOfEachBook: Dictionary< String, Any?> = factor[kies]{
                    if let eachbookAmount: Int = amountOfEachBook["price"] as? Int{
                        totalamount = totalamount + eachbookAmount
                        TotalAmount?.text = "تعداد\(factor.count) کتاب به قیمت \(totalamount)ریال"
                    }
                    
                }
            }
        }
        if desiredPackage.count>0 && (bookCodeEnter.text?.characters.count)! == 0 {
            var totalamount :Int = 0
            for i in 0..<desiredPackage.count{
                if let eachbookAmount : Int = desiredPackage[i]["Price"] as? Int{
                    let eachbookname = desiredPackage[i]["BookName"] as! String
                    packagePrice.append(eachbookAmount)
                    nameOfTheBooksInThePackages.append(eachbookname)
                    totalamount = totalamount + eachbookAmount
                    NameOfThebookAfter?.text = "تعداد\(desiredPackage.count) کتاب به قیمت \(totalamount)ریال "
                }
            }
        }
    }
    func makingRoundBoundries(){
        //Warning.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        TotalAmount.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        NameOfThebookAfter.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        packageCodeEmter.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        nationalcodeenter.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        bookCodeEnter.fullyRound(diameter: 10, borderColor: .lightGray, borderWidth: 3)
        
        
        
    }
    func getPackageInfo(completionHandler: @escaping (NSArray?, Error?) -> ()){
        let urlstr = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/GetIosPackage?NationalCode=\(nationalNumber)"
        Alamofire.request(urlstr).responseJSON{
            response in
            switch response.result{
            case .success(let value):
                
                let result = value as! NSArray
                completionHandler (result, nil)
            case .failure(let error):
                self.Warning?.text = "لطفا اتصال اینترنت را بررسی کنید"
                completionHandler(nil, error)
            }
        }
    }
    
    
}
