import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public protocol ViewRouterServiceProtocol: AnyObject {
    var viewController: UIViewController? { get set }

    func navigate(
        toRoute: Route,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    )
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

    func buildController<T: View>(rootView: T) -> UIViewController {
        let viewController = UIHostingController(rootView: rootView)
        self.viewController = viewController
        return viewController
    }
}

@available(iOS 13.0, *)
final class ViewRouterService: ViewRouterServiceProtocol, Resolvable {
    private var routerService: RouterServiceProtocol?
    weak var viewController: UIViewController?

    func navigate(
        toRoute route: Route,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        guard let routerService = routerService, let viewController = viewController else {
            preconditionFailure("Router service and destination view controller are needed for navigating!")
        }

        routerService.navigate(
            toRoute: route,
            fromView: viewController,
            presentationStyle: presentationStyle,
            animated: animated,
            completion: completion
        )
    }

    func resolve(withStore store: StoreInterface) {
        guard let routerService = store.get(RouterServiceProtocol.self) else {
            preconditionFailure("Expected to find RouterServiceProtocol registered in store!")
        }

        self.routerService = routerService
    }
}
