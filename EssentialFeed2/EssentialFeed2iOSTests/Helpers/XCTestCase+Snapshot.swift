//
//  XCTestCase+Snapshot.swift
//  EssentialFeed2
//
//  Created by Andrey Negovskiy on 10/16/25.
//

import XCTest

extension XCTestCase {
    func record(snapshot data: Data, named name: String, file: StaticString = #file, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(for: name, file: file)
        
        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try data.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
    
    func assert(
        snapshot expectedData: Data,
        named name: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let snapshotURL = makeSnapshotURL(for: name, file: file)
        
        guard let storedData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail(
                "Failed to read snapshot at url: \(snapshotURL). Use `record` first",
                file: file,
                line: line
            )
        }
        
        if storedData != expectedData {
            let temporarySnapshotURL = URL.temporaryDirectory
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? expectedData.write(to: temporarySnapshotURL)
            
            XCTFail(
                """
                New snapshot does not match the stored one. 
                New snapshot: \(temporarySnapshotURL)
                Stored One: \(snapshotURL)
                """,
                file: file,
                line: line
            )
        }
    }
}

private extension XCTestCase {
    private func makeSnapshotURL(for name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
}
