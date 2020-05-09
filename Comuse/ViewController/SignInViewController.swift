//
//  SignInViewController.swift
//  Comuse
//
//  Created by 조현빈 on 2020/05/08.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class SignInViewController: UIViewController, GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // error occured signing in
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        } else {
            // signed in
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                              accessToken: authentication.accessToken)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {(data, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    FirebaseVar.db = Firestore.firestore()
                    FirebaseVar.user = Auth.auth().currentUser
                    Member.addMemberData()
                    
                    self.dismiss(animated: true, completion: nil)
                }})
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
