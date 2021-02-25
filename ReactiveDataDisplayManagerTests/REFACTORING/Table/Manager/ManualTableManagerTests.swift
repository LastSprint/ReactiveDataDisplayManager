//
//  ManualTableManagerTests.swift
//  ReactiveDataDisplayManagerTests
//
//  Created by Anton Eysner on 08.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import XCTest
@testable import ReactiveDataDisplayManager

final class ManualTableManagerTests: XCTestCase {

    private var ddm: ManualTableManager!
    private var table: UITableViewSpy!
    private var dataSource: MockTableDataSource!

    override func setUp() {
        super.setUp()
        table = UITableViewSpy()
        ddm = ManualTableManager()
        dataSource = MockTableDataSource()

        dataSource.provider = ddm
        table.dataSource = dataSource
        ddm.view = table
    }

    override func tearDown() {
        super.tearDown()
        table = nil
        ddm = nil
    }

    // MARK: - Generator actions tests

    func testThatAddSectionGeneratorWorksCorrectly() {
        // given
        let gen1 = MockTableHeaderGenerator()
        let gen2 = MockTableHeaderGenerator()

        // when
        ddm.addSectionHeaderGenerator(gen1)
        ddm.addSectionHeaderGenerator(gen1)
        ddm.addSectionHeaderGenerator(gen2)

        // then
        XCTAssert(ddm.sections.count == 3)
    }

    func testThatAddCellGeneratorAppendsNewSectionToCellGeneratorsCorrectly() {
        // given
        let headerGen = MockTableHeaderGenerator()
        let gen = MockTableCellGenerator()
        let initialNumberOfSections = ddm.generators.count

        // when
        ddm.addSectionHeaderGenerator(headerGen)
        ddm.addCellGenerator(gen)

        // then
        XCTAssert(initialNumberOfSections != ddm.generators.count)
    }

    func testThatAddCellGeneratorCallsRegisterNib() {
        // given
        let headerGen = MockTableHeaderGenerator()
        let gen = MockTableCellGenerator()

        // when
        ddm.addSectionHeaderGenerator(headerGen)
        ddm.addCellGenerator(gen)

        // then
        XCTAssert(table.registerNibWasCalled)
    }

    func testThatCustomOperationAddCellGeneratorCallsRegisterNib() {
        // Arrange
        let headerGen = MockTableHeaderGenerator()
        let gen = MockTableCellGenerator()

        // Act
        ddm.addSectionHeaderGenerator(headerGen)
        ddm += gen

        // Assert
        XCTAssert(table.registerNibWasCalled)
    }

    func testThatCustomOperationAddCellGeneratorsCallsRegisterNib() {
        // Arrange
        let headerGen = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()

        // Act
        ddm.addSectionHeaderGenerator(headerGen)
        ddm += [gen1, gen2]

        // Assert
        XCTAssert(table.registerNibWasCalled)
        XCTAssert(ddm.generators[0].count == 2)
    }

    func testThatAddCellGeneratorAddsEmptyHeaderIfThereIsNoCellHeaderGenerators() {
        // given
        let gen = MockTableCellGenerator()

        // when
        ddm.addCellGenerator(gen)

        // then
        XCTAssert(ddm.sections.count == 1)
    }

    func testThatAddCellGeneratorAddsGeneratorCorrectly() {
        // given
        let headerGen = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()

        // when
        ddm.addSectionHeaderGenerator(headerGen)
        ddm.addCellGenerator(gen1)
        ddm.addCellGenerator(gen1)
        ddm.addCellGenerator(gen1)
        ddm.addSectionHeaderGenerator(headerGen)
        ddm.addCellGenerator(gen2)
        ddm.addCellGenerator(gen2)

        // then
        XCTAssert(ddm.generators.count == 2)
        XCTAssert(ddm.generators.first?.count == 3)
        XCTAssert(ddm.generators.last?.count == 2)
    }

    func testThatAddCellGeneratorAfterGeneratorWorksCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen3 = MockTableCellGenerator()
        let gen4 = MockTableCellGenerator()
        let gen5 = MockTableCellGenerator()

        // when
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerator(gen1)
        ddm.addCellGenerator(gen2, after: gen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen3, gen5])
        ddm.addCellGenerator(gen4, after: gen3)

        // then
        XCTAssert(ddm.generators[0][0] === gen1 && ddm.generators[0][1] === gen2)
        XCTAssert(ddm.generators[1][0] === gen3 && ddm.generators[1][1] === gen4 && ddm.generators[1][2] === gen5)
    }

    func testThatAddCellGeneratorAfterGeneratorCallsFatalErrorCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        self.ddm.addSectionHeaderGenerator(headerGen1)

        // when
        expectFatalError(expectedMessage: "Error adding TableCellGenerator generator. You tried to add generators after unexisted generator") {
            self.ddm.addCellGenerator(gen2, after: gen1) // then
        }
    }

    func testThatUpdateGeneratorsUpdatesNeededGenerators() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen3 = MockTableCellGenerator()
        let gen4 = MockTableCellGenerator()
        let gen5 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen2])
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen3, gen4, gen5])

        // when
        ddm.update(generators: [gen1, gen4])

        // then
        XCTAssert(table.lastReloadedRows == [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 1)])
    }

    func testThatClearCellGeneratorsWorksCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen1, gen2, gen2])
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen1, gen2, gen2])

        // when
        ddm.clearCellGenerators()

        // then
        XCTAssert(ddm.generators.isEmpty)
    }

    func testThatClearHeaderGeneratorsWorksCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen1, gen2, gen2])
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen1, gen2, gen2])

        // when
        ddm.clearHeaderGenerators()

        // then
        XCTAssert(ddm.sections.isEmpty)
    }

    func testThatAddCellGeneratorToHeaderAddsGeneratorsToCorrectHeader() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)

        // when
        ddm.addCellGenerator(gen1, toHeader: headerGen1)
        ddm.addCellGenerator(gen1, toHeader: headerGen1)
        ddm.addCellGenerator(gen1, toHeader: headerGen1)
        ddm.addCellGenerator(gen2, toHeader: headerGen2)

        // then
        XCTAssert(ddm.generators.first?.count == 3)
        XCTAssert(ddm.generators.last?.count == 1)
    }

    // MARK: - Table actions tests

    func testThatRemoveGeneratorRemovesEmptySections() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen3 = MockTableCellGenerator()
        let gen4 = MockTableCellGenerator()

        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen2], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen3, gen4], toHeader: headerGen2)

        let group = DispatchGroup()
        group.enter()

        // when
        ddm.remove(gen3, needRemoveEmptySection: true) { group.leave() }
        ddm.remove(gen4, needRemoveEmptySection: true) { group.leave() }

        // then
        group.notify(queue: .main) { [weak self] in
            XCTAssert(self?.ddm.sections.count == 1)
            XCTAssert(self?.ddm.generators.count == 1)
        }
    }

    func testThatRemoveGeneratorCallsScrolling() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen3 = MockTableCellGenerator()
        let gen4 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen2], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen3, gen4], toHeader: headerGen2)

        // when
        ddm.remove(gen3, needScrollAt: .top) { [weak self] in
            // then
            XCTAssert(self?.table.scrollToRowWasCalled == true)
        }
    }

    func testThatRemoveGeneratorRemovesGenerators() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen3 = MockTableCellGenerator()
        let gen4 = MockTableCellGenerator()

        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen2], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen3, gen4], toHeader: headerGen2)

        // when
        ddm.remove(gen1) { [weak self] in
            // then
            XCTAssert(self?.ddm.generators.first?.first === gen2)
            XCTAssert(self?.ddm.generators.first?.count == 1)
        }
    }

    func testThatInsertGeneratorAfterGeneratorInsertsGeneratorOnCorrectPosition() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let gen3 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen4 = MockTableCellGenerator()
        let gen5 = MockTableCellGenerator()
        let gen6 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen3], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen4, gen6], toHeader: headerGen2)

        // when
        ddm.insert(after: gen1, new: gen2)
        ddm.insert(after: gen4, new: gen5)

        // then
        XCTAssert(ddm.generators[0][0] === gen1 && ddm.generators[0][1] === gen2 && ddm.generators[0][2] === gen3)
        XCTAssert(ddm.generators[1][0] === gen4 && ddm.generators[1][1] === gen5 && ddm.generators[1][2] === gen6)
    }

    func testThatInsertGeneratorBeforeGeneratorInsertsGeneratorOnCorrectPosition() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let gen3 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen4 = MockTableCellGenerator()
        let gen5 = MockTableCellGenerator()
        let gen6 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen2, gen3], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen5, gen6], toHeader: headerGen2)

        // when
        ddm.insert(before: gen2, new: gen1)
        ddm.insert(before: gen5, new: gen4)

        // then
        XCTAssert(ddm.generators[0][0] === gen1 && ddm.generators[0][1] === gen2 && ddm.generators[0][2] === gen3)
        XCTAssert(ddm.generators[1][0] === gen4 && ddm.generators[1][1] === gen5 && ddm.generators[1][2] === gen6)
    }

    func testThatInsertGeneratorToHeaderInsertsGeneratorOnCorrectPosition() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let gen3 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen4 = MockTableCellGenerator()
        let gen5 = MockTableCellGenerator()
        let gen6 = MockTableCellGenerator()

        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen2, gen3], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen5, gen6], toHeader: headerGen2)

        // when
        ddm.insert(to: headerGen1, new: gen1)
        ddm.insert(to: headerGen2, new: gen4)

        // then
        XCTAssert(ddm.generators[0][0] === gen1 && ddm.generators[0][1] === gen2 && ddm.generators[0][2] === gen3)
        XCTAssert(ddm.generators[1][0] === gen4 && ddm.generators[1][1] === gen5 && ddm.generators[1][2] === gen6)
    }

    func testThatReplaceOldGeneratorOnNewReplacesGeneratorCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let gen2 = MockTableCellGenerator()
        let gen3 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1, gen2], toHeader: headerGen1)

        // when
        ddm.replace(oldGenerator: gen1, on: gen3) { [weak self] in
            // then
            XCTAssert(self?.ddm.generators[0][0] === gen3 && self?.ddm.generators[0][1] === gen2)
        }
    }

    func testThatSwapGeneratorWithGeneratorSwapsCorrectly() {
        // given
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen2 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen2], toHeader: headerGen2)

        // when
        ddm.swap(generator: gen1, with: gen2)

        // then
        XCTAssert(ddm.generators[0][0] === gen2 && ddm.generators[1][0] === gen1)
    }

    func testThatReloadSectionCallTableViewMethod() {
        // Arrange
        let headerGenerator = MockTableHeaderGenerator()
        ddm.addSectionHeaderGenerator(headerGenerator)

        // Act
        ddm.reloadSection(by: headerGenerator)

        // Assert
        XCTAssert(table.sectionWasReloaded)
    }

    func testThatReloadSectionWithInvalidHeaderGeneratorNotCallTableViewMethod() {
        // Arrange
        let headerGenerator = MockTableHeaderGenerator()
        let wrongHeaderGenerator = MockTableHeaderGenerator()
        ddm.addSectionHeaderGenerator(headerGenerator)

        // Act
        ddm.reloadSection(by: wrongHeaderGenerator)

        // Assert
        XCTAssertFalse(table.sectionWasReloaded)
    }

    func testThatRemoveAllGeneratorsClearsSection() {
        // Arrange
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        let gen2 = MockTableCellGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1], toHeader: headerGen1)
        ddm.addSectionHeaderGenerator(headerGen2)
        ddm.addCellGenerators([gen2], toHeader: headerGen2)

        // Act
        ddm.removeAllGenerators(from: headerGen2)

        // Assert
        XCTAssert(table.numberOfSections == 2)
        XCTAssert(table.numberOfRows(inSection: 0) == 1, "Expected 1, got \(table.numberOfRows(inSection: 0))")
        XCTAssert(table.numberOfRows(inSection: 1) == 0, "Expected 0, got \(table.numberOfRows(inSection: 1))")
    }

    func testThatRemoveAllGeneratorsDoesntClearInvalidSection() {
        // Arrange
        let headerGen1 = MockTableHeaderGenerator()
        let gen1 = MockTableCellGenerator()
        let headerGen2 = MockTableHeaderGenerator()
        ddm.addSectionHeaderGenerator(headerGen1)
        ddm.addCellGenerators([gen1], toHeader: headerGen1)

        // Act
        ddm.removeAllGenerators(from: headerGen2)

        // Assert
        XCTAssert(table.numberOfSections == 1)
        XCTAssert(table.numberOfRows(inSection: 0) == 1)
        XCTAssert(table.numberOfRows(inSection: 0) == 1, "Expected 1, got \(table.numberOfRows(inSection: 0))")
    }

}
