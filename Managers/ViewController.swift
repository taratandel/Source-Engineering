//
//  ViewController.swift
//  Managers
//
//  Created by negar on 96/Khordad/30 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var loginInfo: UILabel!
    @IBOutlet weak var nationalCode: UITextField!
    @IBOutlet weak var LoginBackground: UIImageView!
    var nationalNumber : [NSManagedObject] = []
    
    //navigation controll
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//        tabbarhideen?.tabBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = false

    }
    override func viewDidAppear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = true

    }
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.tabBarController?.tabBar.isHidden = true

        self.hideKeyboardWhenTappedAround()
        
        LoginBackground?.image = #imageLiteral(resourceName: "Login")
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func enter(_ sender: UIButton) {
        if (self.nationalCode.text?.characters.count)!>0{
        if let nationalcode: String = self.nationalCode.text!{
            print(nationalcode)

        let urlString = "http://city.kanoon.ir/newsite/Common/WebService/WSPublicApp.asmx/LoginAccess?NationalCode=\(nationalcode)"
        checkNationalCodeForEnter(urlString: urlString){
            returnedAnswer, error in
        
                if (returnedAnswer==0) {
                    self.loginInfo.text = "کد ملی اشتباه است!"
                    self.loginInfo.textColor = UIColor.red
                }
                
                else{
                    
                    //save the national number in coredata
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    let managedContext =
                        appDelegate.persistentContainer.viewContext
                    
                    // 2
                    let entity =
                        NSEntityDescription.entity(forEntityName: "IsLoggedIn",
                                                   in: managedContext)!
                    
                    let person = NSManagedObject(entity: entity,
                                                 insertInto: managedContext)
                    
                    person.setValue(nationalcode, forKeyPath: "groupCode")
                    
                    // 4
                    do {
                        try managedContext.save()
                        self.nationalNumber.append(person)
                        print(self.nationalNumber[0])
                        self.performSegue(withIdentifier: "validLogin", sender: self)
                    }//if saving fail
                    catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        }
        }
            else {
                self.loginInfo.text = " شماره ملی خود را وارد کنید"
                self.loginInfo.textColor = UIColor.red
            }
        }
    
    
    func checkNationalCodeForEnter(urlString : String, completionHandler: @escaping (Int?, Error?)-> ()) -> () {
        Alamofire.request(urlString).responseJSON { response in
            if NetworkReachabilityManager()!.isReachable{
                if let res : Int = response.result.value as? Int {
                    completionHandler(res , nil)
                }
                else {
                    self.loginInfo.text = "اینترنت خود را بررسی کنید"
                    self.loginInfo.textColor = UIColor.blue
                }
                
            }
        }
    }
}

