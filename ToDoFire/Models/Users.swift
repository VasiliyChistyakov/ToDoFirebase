//
//  User.swift
//  ToDoFire
//
//  Created by Чистяков Василий Александрович on 19.12.2021.
//

import Foundation
import Firebase

struct Users {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
