import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
public protocol ViewRouterServiceProtocol: AnyObject {
    func navigate<T: View>(
        toRoute: Route,
        fromView: T.Type,
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
    func navigate<T: View>(
        toRoute route: Route,
        fromView view: T.Type,
        presentationStyle: PresentationStyle,
        animated: Bool
    ) {
        navigate(
            toRoute: route,
            fromView: view,
            presentationStyle: presentationStyle,
            animated: animated,
            completion: nil
        )
    }
}

@available(iOS 13.0, *)
final class ViewRouterService: ViewRouterServiceProtocol, Resolvable {
    private let failureHandler: () -> Void
    private let viewControllers = NSMapTable<NSString, UIViewController>(
        keyOptions: .strongMemory,
        valueOptions: .weakMemory
    )

    private(set) weak var routerService: RouterServiceProtocol?

    init(
        failureHandler: @escaping () -> Void = { preconditionFailure() }
    ) {
        self.failureHandler = failureHandler
    }

    func navigate<T: View>(
        toRoute route: Route,
        fromView _: T.Type,
        presentationStyle: PresentationStyle,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        let identifier = String(describing: T.self) as NSString

        guard
            let routerService = routerService,
            let viewController = viewControllers.object(forKey: identifier)
        else {
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

        // BUG: Impossible to push two views of the same type
        let identifier = String(describing: T.self) as NSString
        viewControllers.setObject(viewController, forKey: identifier)

        return viewController
    }

    func resolve(withStore store: StoreInterface) {
        guard let routerService = store.get(RouterServiceProtocol.self) else {
            return failureHandler()
        }

        self.routerService = routerService
    }
}
