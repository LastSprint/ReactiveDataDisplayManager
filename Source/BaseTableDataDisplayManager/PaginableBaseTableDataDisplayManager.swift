import Foundation

open class PaginableBaseTableDataDisplayManager: BaseTableDataDisplayManager {

    /// Called if table shows last cell
    public var lastCellShowingEvent = BaseEvent<Void>()

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = cellGenerators.count - 1
        let lastCellInLastSectionIndex = cellGenerators[lastSectionIndex].count - 1
        let lastCellIndexPath = IndexPath(row: lastCellInLastSectionIndex, section: lastSectionIndex)
        if indexPath == lastCellIndexPath {
            lastCellShowingEvent.invoke(with: ())
        }
    }
}
