//
//  OrderListViewController.swift
//  Managers
//
//  Created by Tara Tandel on 4/2/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire

extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
class OrderListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UINavigationControllerDelegate, XMLParserDelegate {
    
    var factor = [Int : Dictionary<String, Any?>]()
    var JsoonFactor = [[String : Any?]]()
    var is_backclicked = true
    fileprivate var parsedXMLString: String?
    fileprivate var parsedElementValue: String?
    
    @IBOutlet weak var BooksBeenChosen: UITableView!
    @IBOutlet weak var backGround: UIImageView!
    
    @IBOutlet weak var TotalAmount: UILabel!
    var factorid = Int()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
       // navigationController?.navigationBar.isHidden = true

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        makingRoundedBoundrie()
        navigationController?.navigationBar.isHidden = false
        // Use the edit button item provided by the table view controller.
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.delegate = self
        
        backGround?.image = #imageLiteral(resourceName: "FinalOrder")
        changeFactorForserialization()
        calculatingtotalamount()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return factor.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell" , for : indexPath) 
        let eachBookId = JsoonFactor[indexPath.row]["bookId"] as! Int
        let eachBook = factor[eachBookId]
        let eachBookName = eachBook?["bookName"] as? String
        let eachBookInttoString = eachBook?["price"] as! Int
        cell.textLabel?.text = "ریال\(eachBookInttoString)"
        cell.detailTextLabel?.text = eachBookName
        return cell
    }
    
    func changeFactorForserialization (){
            
                    
        for (bookids,_) in factor {
            JsoonFactor.append(factor[bookids]!)
        }
        
    }
    
    func calculatingtotalamount(){
        var totalamount :Int = 0
        for (kies, _) in factor {
            if let amountOfEachBook: Dictionary< String, Any?> = factor[kies]{
                if let eachbookAmount: Int = amountOfEachBook["price"] as? Int{
                    totalamount = totalamount + eachbookAmount
                    if totalamount != 0{
                        TotalAmount?.text = "\(totalamount)ریال "
                    
                    }
                    else {
                        TotalAmount?.text = "کتابی وجود ندارد"
                    }
                }
                
            }
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let detailOfDeletedBook = JsoonFactor[indexPath.row]
            let BookId = detailOfDeletedBook ["bookId"] as! Int
            factor.removeValue(forKey: BookId)
            JsoonFactor.remove(at: indexPath.row)
            calculatingtotalamount()
            if factor.count == 0 {
                TotalAmount?.text = " کتابی را به سبد انتخاب اضافه کنید"
            }
            BooksBeenChosen.reloadData()
        } else if editingStyle == .insert {
            performSegue(withIdentifier: "backToChangeTheBasket", sender: self)
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToChangeTheBasket"
        {
            let BookEnterView = segue.destination as! BookEnteryViewController
            if is_backclicked{
            BookEnterView.factor = factor
            }
            else{
            BookEnterView.factorid = factorid
            }
        }
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? BookEnteryViewController)?.factor = factor
    }

    @IBAction func FinalizeOrder(_ sender: Any) {
//        do{
//        let data = try JSONSerialization.data(withJSONObject: JsoonFactor, options: .prettyPrinted)
//
//        Alamofire.request("http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx?op=InsertIosFactor", .post, parameters: data, encoding: JSONEncoding.default)
//        
////        }
//        var dic = [String: Any]()
//        for item in JsoonFactor {
//            for (kind, value) in item {
//                print(kind)
//                dic.updateValue(value!, forKey: kind)
//            }
//            
//            
//        }
//        let headers = [
//            "Content-Type": "application/x-www-form-urlencoded"
//        ]
//        var param : Parameters? = dic
//        Alamofire.request("http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx?op=InsertIosFactor", method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseString{
//                            response in
//                            switch response.result{
//                            case .success (let value):
//                                if let result: NSDictionary = value as? NSDictionary{
//                                    if let res: Int = result["FactorId"] as? Int{
//                                    self.factorid = res
//                                        self.is_backclicked = false
//                                        let alertController = UIAlertController(title: "شماره فاکتور", message: "شماره فاکتور شما \(self.factorid)", preferredStyle: .alert)
//                                        let segueAction = UIAlertAction(title: "تایید ", style: .default){
//                                            alert in
//                                            self.performSegue(withIdentifier: "backToChangeTheBasket", sender: self)
//                                        }
//                                        alertController.addAction(segueAction)
//                                        self.present(alertController, animated: true, completion: nil)
//                                        print(self.factorid)
//                                    }
//            
//                                }
//                            case .failure(let error):
//                                
//                                print("fail")
//                            }
//                            
//                        // Trigger alaomofire request with url
//                    }
//        catch let error as Error{
//            print(error)
////        }
        for i in 0..<JsoonFactor.count{
            JsoonFactor[i].removeValue(forKey: "bookName")
        
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: JsoonFactor, options: .prettyPrinted)
            let jsonString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            let jr = (jsonString?.replacingOccurrences(of: "\n", with: "", options: .regularExpression))!
            let jrrr = jr.removingWhitespaces()
            let urlEncodedJson = jrrr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
//        var aString : String = ""
//        for aBook in JsoonFactor {
//            if let nationalCode : String = aBook["nationalCode"] as? String{
//                aString.append("nationalCode : " + nationalCode + ", ")
//            }
//            if let bookId : String = aBook["bookId"] as? String{
//                aString.append("bookId : " + bookId + ", ")
//            }
//            // and so on, and so forth
//        }
//            let trimmedString = jr.trimmingCharacters(in: .whitespaces)
       // let urlEncodedJson : String = urlStrings()
             let urlString = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/InsertIosFactor?FactorInfo=\(urlEncodedJson!)"
            Alamofire.request(urlString).responseString{
                response in
                switch response.result{
                case .success (let value):
                    if let resul: String = value as? String{
                        let result = self.convertToDictionary(text: resul)
                        if let res: Int = result?["FactorId"] as? Int{
                        self.factorid = res
                            self.is_backclicked = false
                            let alertController = UIAlertController(title: "شماره فاکتور", message: "شماره فاکتور شما \(self.factorid)", preferredStyle: .alert)
                            let segueAction = UIAlertAction(title: "تایید ", style: .default){
                                alert in
                                self.factor = [ : ]
                                self.performSegue(withIdentifier: "backToChangeTheBasket", sender: self)
                            }
                            alertController.addAction(segueAction)
                            self.present(alertController, animated: true, completion: nil)
                            print(self.factorid)
                        }
                        
                    }
                case .failure(let error):
                    
                    print(error)
                }
                
            // Trigger alaomofire request with url
        }
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
    }

    func makingRoundedBoundrie(){
        BooksBeenChosen.fullyRound(diameter: 20, borderColor: .lightGray, borderWidth: 3)
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
