import XCTest

import DummyTests

var tests = [XCTestCaseEntry]()
tests += DummyTests.allTests()
XCTMain(tests)
