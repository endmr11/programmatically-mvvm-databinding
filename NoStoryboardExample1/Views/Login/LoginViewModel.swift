//
//  LoginViewModel.swift
//  NoStoryboardExample1
//
//  Created by Eren Demir on 5.03.2023.
//

import Foundation
import Combine

final class LoginViewModel {
    final var apiService = APIService()
    var credentials = LoginCredentials(email: "", password: "")
    
    func login() async -> AnyPublisher<User, Error> {
        do {
            let user = try await self.apiService.mockLoginRequest(email: self.credentials.email, password: self.credentials.password)
            return Just(user)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
        } catch {
            print(error.localizedDescription)
            return Fail(error: LoginError.invalidCredentials)
                    .eraseToAnyPublisher()
        }
    }
//    func login() -> AnyPublisher<User, Error> {
//        let future = Future<User, Error> { promise in
//            self.apiService.mockLoginRequest(email: self.credentials.email, password: self.credentials.password) { result in
//                switch result {
//                case .failure(let error):
//                    promise(.failure(error))
//                case .success(let user):
//                    promise(.success(user))
//                }
//            }
//        }
//        return future.eraseToAnyPublisher()
//    }
}
