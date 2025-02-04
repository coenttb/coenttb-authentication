//
//  File.swift
//  coenttb-authentication
//
//  Created by Coen ten Thije Boonkkamp on 04/02/2025.
//

import Foundation
import BasicAuth
import EmailAddress

extension BasicAuth {
    public init(
        email: EmailAddress,
        password: String
    ){
        self = .init(username: email.rawValue, password: password)
    }
}
