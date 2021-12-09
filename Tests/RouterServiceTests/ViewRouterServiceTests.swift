import XCTest
import SwiftUI

@testable import RouterService
@testable import RouterServiceInterface

final class ViewRouterServiceTests: XCTestCase {

    func test_viewRouterSerivce_failsToResolveIfTheresNoRouterRegistered() {
        let store = RouterServiceDoubles.StoreSpy()
        var didFail = false

        let viewRouterService = ViewRouterService(failureHandler: {
            didFail = true
        })

        viewRouterService.resolve(withStore: store)

        XCTAssertTrue(didFail)
    }

    func test_viewRouterService_resolvesIfRouterIsRegistered() {
        let viewRouterService = ViewRouterService()
        let routerService = RouterService()
        let store = Store()

        store.register({ routerService }, forMetaType: RouterServiceProtocol.self)

        viewRouterService.resolve(withStore: store)

        XCTAssertTrue(viewRouterService.routerService === routerService)
    }

    func test_viewRouterService_failsRoutingIfTheresNoRouterRegistered() {
        var didFail = false

        let viewRouterService = ViewRouterService(failureHandler: {
            didFail = true
        })

        let route = RouterServiceDoubles.MockRouteFromFooHandler()
        viewRouterService.navigate(toRoute: route, presentationStyle: Push(), animated: false)

        XCTAssertTrue(didFail)
    }

    func test_viewRouterService_failsRoutingIfTheresNoViewControllerBuilt() {
        let routerService = RouterService()
        let store = Store()

        store.register({ routerService }, forMetaType: RouterServiceProtocol.self)

        var didFail = false
        let viewRouterService = ViewRouterService(failureHandler: {
            didFail = true
        })

        let route = RouterServiceDoubles.MockRouteFromFooHandler()
        viewRouterService.navigate(toRoute: route, presentationStyle: Push(), animated: false)

        XCTAssertTrue(didFail)
    }

    func test_viewRouterService_succeedsRoutingIfTheresRouterRegisteredAndViewController() {
        let viewRouterService = ViewRouterService()
        let routerServiceSpy = RouterServiceSpy()
        let store = Store()

        store.register({ routerServiceSpy }, forMetaType: RouterServiceProtocol.self)

        viewRouterService.resolve(withStore: store)
        let viewController = viewRouterService.buildController(rootView: DummyView())

        let route = RouterServiceDoubles.MockRouteFromFooHandler()
        viewRouterService.navigate(toRoute: route, presentationStyle: Push(), animated: false)

        XCTAssertTrue(routerServiceSpy.invokedNavigate)
        XCTAssertTrue(routerServiceSpy.viewController === viewController)
    }

    private struct DummyView: View {
        var body: some View { Text("Test!") }
    }

    private final class RouterServiceSpy: RouterServiceProtocol {
        private(set) var viewController: UIViewController?
        var invokedNavigate: Bool {
            viewController != nil
        }

        func navigate(
            toRoute _: Route,
            fromView viewController: UIViewController,
            presentationStyle _: PresentationStyle,
            animated _: Bool,
            completion _: (() -> Void)?
        ) { self.viewController = viewController }

        func decodeAnyRoute(fromDecoder decoder: Decoder) throws -> (Route, String) {
            fatalError()
        }
    }
}
