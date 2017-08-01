//
//  AppStartViewController.swift
//  Managers
//
//  Created by Tara Tandel on 3/31/1396 AP.
//  Copyright © 1396 negar. All rights reserved.
//

import UIKit
import CoreData

class AppStartViewController: UIViewController {
    
    @IBOutlet weak var Vorood: UIImageView!
    
    var CheckforLoggin: [NSManagedObject] = [] //for cheking if the user has loogedin before
    
    //these 2 funca are for navigationbar
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated);
        super.viewWillDisappear(animated)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Vorood.image = #imageLiteral(resourceName: "shoro")
        
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
            CheckforLoggin = try managedContext.fetch(fechtRequest)
        }
        catch let error as NSError {
            //if not shows the error
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {

        self.checktooChooseSegue()
            
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checktooChooseSegue(){
        
        if CheckforLoggin.count>0{
            
            performSegue(withIdentifier: "loggedinBefore", sender: self)
            
        }
        
        else {
            performSegue(withIdentifier: "notLoggedinBefore", sender: self)
        }
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
