import Foundation
import UIKit

public protocol RouterServiceProtocol: AnyObject, RouterServiceAnyRouteDecodingProtocol {
    func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    )
}

public extension RouterServiceProtocol {
    func navigate(
        toRoute route: Route,
        fromView viewController: UIViewController,
        presentationStyle: PresentationStyle,
        animated: Bool
    ) {
        navigate(
            toRoute: route,
            fromView: viewController,
            presentationStyle: presentationStyle,
            animated: animated,
            completion: nil
        )
    }
}

public typealias DependencyFactory = () -> AnyObject

public protocol RouterServiceRegistrationProtocol {
    func register<T>(dependencyFactory: @escaping DependencyFactory, forType metaType: T.Type)
    func register(routeHandler: RouteHandler)
}

@available(iOS 13.0, *)
public extension RouterServiceRegistrationProtocol {
    func registerViewRouterService() {
        register(
            dependencyFactory: { ViewRouterService() },
            forType: ViewRouterServiceProtocol.self
        )
    }
}

public protocol RouterServiceScopeProtocol {
    func register(scope: String)
    func enter(scope: String)
    func leave(scope: String)
}
