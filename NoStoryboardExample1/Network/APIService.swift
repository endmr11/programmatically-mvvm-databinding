//
//  APIService.swift
//  NoStoryboardExample1
//
//  Created by Eren Demir on 5.03.2023.
//

import Foundation


final class APIService {
    
//    func mockLoginRequest(email: String,password: String, completion:@escaping (Result<User, Error>)->Void) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            if email == "eren@gmail.com" && password == "123" {
//                let user = User(username: "Eren")
//                completion(.success(user))
//            } else {
//                completion(.failure(LoginError.invalidCredentials))
//            }
//        }
//    }
    func mockLoginRequest(email: String, password: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if email == "eren@gmail.com" && password == "123" {
                    let user = User(username: "Eren")
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: LoginError.invalidCredentials)
                }
            }
        }
    }
}
