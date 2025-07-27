//
//  File.swift
//  coenttb-mailgun
//
//  Created by Coen ten Thije Boonkkamp on 20/12/2024.
//
import URLRouting
import Authentication
import Foundation
import Dependencies
import Coenttb_Web_Dependencies

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@dynamicMemberLookup
public struct Client<
    Auth: Equatable & Sendable,
    AuthRouter: ParserPrinter & Sendable,
    API: Equatable & Sendable,
    APIRouter: ParserPrinter & Sendable,
    ClientOutput: Sendable
>: Sendable
where
APIRouter.Input == URLRequestData,
APIRouter.Output == API,
AuthRouter.Input == URLRequestData,
AuthRouter.Output == Auth
{
    
    private let baseURL: URL
    private let auth: Auth
    
    private let router: APIRouter
    private let buildClient: @Sendable (@escaping @Sendable (API) throws -> URLRequest) -> ClientOutput
    private let authenticatedRouter: Coenttb_Authentication.API<Auth, API>.Router<AuthRouter, APIRouter>
    
    @Dependency(\.defaultSession) var session
    
    public init(
        baseURL: URL,
        auth: Auth,
        router: APIRouter,
        authRouter: AuthRouter,
        buildClient: @escaping @Sendable (@escaping @Sendable (API) throws -> URLRequest) -> ClientOutput
    ) {
        self.baseURL = baseURL
        self.auth = auth
        self.router = router
        self.buildClient = buildClient
        self.authenticatedRouter = Coenttb_Authentication.API.Router(
            baseURL: baseURL,
            authRouter: authRouter,
            router: router
        )
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<ClientOutput, T>) -> T {
        @Sendable
        func makeRequest(for api: API) throws -> URLRequest {
            do {
                let data = try authenticatedRouter.print(.init(auth: auth, api: api))
                
                guard let request = URLRequest(data: data) else {
                    throw Error.requestError
                }
                
                return request
            } catch {
                throw Error.printError
            }
        }
        
        return withEscapedDependencies { dependencies in
             buildClient { api in
                 try dependencies.yield {
                    try makeRequest(for: api)
                }
            }[keyPath: keyPath]
        }
    }
}

public enum Error: Swift.Error {
    case printError
    case requestError
}


// MARK: CONVENIENCES
extension Client {
    public init(
        baseURL: URL,
        token: String,
        buildClient: @escaping @Sendable (
            _ makeRequest: @escaping @Sendable (_ route: API) throws -> URLRequest
        ) -> ClientOutput
    ) throws where Auth == BearerAuth, AuthRouter == BearerAuth.Router, APIRouter: TestDependencyKey, APIRouter.Value == APIRouter {
        @Dependency(APIRouter.self) var router
        
        self = Client.init(
            baseURL: baseURL,
            auth: try .init(token: token),
            router: router,
            authRouter: BearerAuth.Router(),
            buildClient: buildClient
        )
    }
}

extension Client where APIRouter: TestDependencyKey, APIRouter.Value == APIRouter {
    public init(
        baseURL: URL,
        token: String,
        buildClient: @escaping @Sendable () -> ClientOutput
    ) throws where Auth == BearerAuth, AuthRouter == BearerAuth.Router {
        @Dependency(APIRouter.self) var router
        self = try .init(
            baseURL: baseURL,
            token: token,
            buildClient: { _ in buildClient() }
        )
    }
}

extension Client {
    public init(
        baseURL: URL,
        username: String,
        password: String,
        buildClient: @escaping @Sendable (
            _ makeRequest: @escaping @Sendable (_ route: API) throws -> URLRequest
        ) -> ClientOutput
    ) throws where Auth == BasicAuth, AuthRouter == BasicAuth.Router, APIRouter: TestDependencyKey, APIRouter.Value == APIRouter {
        @Dependency(APIRouter.self) var router
        
        self = Client.init(
            baseURL: baseURL,
            auth: try .init(username: username, password: password),
            router: router,
            authRouter: BasicAuth.Router(),
            buildClient: buildClient
        )
    }
}

extension Client where APIRouter: TestDependencyKey, APIRouter.Value == APIRouter {
    public init(
        baseURL: URL,
        username: String,
        password: String,
        buildClient: @escaping @Sendable () -> ClientOutput
    ) throws where Auth == BasicAuth, AuthRouter == BasicAuth.Router {
        @Dependency(APIRouter.self) var router
        self = try .init(
            baseURL: baseURL,
            username: username,
            password: password,
            buildClient: { _ in buildClient() }
        )
    }
}
