import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public protocol ViewRouterServiceProtocol: AnyObject {
    func navigate(
        toRoute: Route,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    )
    func buildController<T: View>(
        rootView: T
    ) -> UIViewController
}

@available(iOS 13.0, *)
public extension ViewRouterServiceProtocol {
    func navigate(
        toRoute route: Route,
        presentationStyle: PresentationStyle,
        animated: Bool
    ) {
        navigate(
            toRoute: route,
            presentationStyle: presentationStyle,
            animated: animated,
            completion: nil
        )
    }
}

@available(iOS 13.0, *)
final class ViewRouterService: ViewRouterServiceProtocol, Resolvable {
    private let failureHandler: () -> Void

    private(set) weak var routerService: RouterServiceProtocol?
    private(set) weak var viewController: UIViewController?

    init(
        failureHandler: @escaping () -> Void = { preconditionFailure() }
    ) {
        self.failureHandler = failureHandler
    }

    func navigate(
        toRoute route: Route,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let routerService = routerService, let viewController = viewController else {
            return failureHandler()
        }

        routerService.navigate(
            toRoute: route,
            fromView: viewController,
            presentationStyle: presentationStyle,
            animated: animated,
            completion: completion
        )
    }

    func buildController<T: View>(rootView: T) -> UIViewController {
        let viewController = UIHostingController(rootView: rootView)
        self.viewController = viewController
        return viewController
    }

    func resolve(withStore store: StoreInterface) {
        guard let routerService = store.get(RouterServiceProtocol.self) else {
            return failureHandler()
        }

        self.routerService = routerService
    }
}
