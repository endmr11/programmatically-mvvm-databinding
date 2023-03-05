//
//  LoginModel.swift
//  NoStoryboardExample1
//
//  Created by Eren Demir on 5.03.2023.
//

import Foundation

struct LoginCredentials {
  let email: String
  let password: String
}

struct User {
  let username: String
}

enum LoginError: Error {
  case invalidCredentials
}
