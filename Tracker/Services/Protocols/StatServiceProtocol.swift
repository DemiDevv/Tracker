import Foundation

// MARK: - StatService + StatServiceProtocol

protocol StatServiceProtocol {
    func getStatistic() -> [StatModel]
}
