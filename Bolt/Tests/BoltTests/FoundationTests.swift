import Foundation
import Testing
@testable import Bolt

struct IntTests {
    @Test func red() {
        #expect(0x000000.red == 0.0)
        #expect(0x333333.red == 0.2)
        #expect(0xCCCCCC.red == 0.8)
        #expect(0xFFFFFF.red == 1.0)
        #expect(0xFF0000.red == 1.0)
        #expect(0x00FF00.red == 0.0)
        #expect(0x0000FF.red == 0.0)
    }

    @Test func green() {
        #expect(0x000000.green == 0.0)
        #expect(0x333333.green == 0.2)
        #expect(0xCCCCCC.green == 0.8)
        #expect(0xFFFFFF.green == 1.0)
        #expect(0xFF0000.green == 0.0)
        #expect(0x00FF00.green == 1.0)
        #expect(0x0000FF.green == 0.0)
    }

    @Test func blue() {
        #expect(0x000000.blue == 0.0)
        #expect(0x333333.blue == 0.2)
        #expect(0xCCCCCC.blue == 0.8)
        #expect(0xFFFFFF.blue == 1.0)
        #expect(0xFF0000.blue == 0.0)
        #expect(0x00FF00.blue == 0.0)
        #expect(0x0000FF.blue == 1.0)
    }

    @Test func componentsInit() {
        #expect(Int([0.0, 0.0, 0.0, 1.0]) == 0x000000)
        #expect(Int([0.0, 1.0]) == 0x000000)
        #expect(Int([0.2, 0.2, 0.2, 1.0]) == 0x333333)
        #expect(Int([0.2, 1.0]) == 0x333333)
        #expect(Int([0.8, 0.8, 0.8, 1.0]) == 0xCCCCCC)
        #expect(Int([0.8, 1.0]) == 0xCCCCCC)
        #expect(Int([1.0, 1.0, 1.0, 1.0]) == 0xFFFFFF)
        #expect(Int([1.0, 1.0]) == 0xFFFFFF)
        #expect(Int([1.0, 0.0, 0.0, 1.0]) == 0xFF0000)
        #expect(Int([0.0, 1.0, 0.0, 1.0]) == 0x00FF00)
        #expect(Int([0.0, 0.0, 1.0, 1.0]) == 0x0000FF)
        #expect(Int([]) == 0x000000)
        #expect(Int(nil) == 0x000000)
        #expect(Int() == 0x000000)
    }
}

struct StringTests {
    @Test func hex() {
        #expect("#FFFFFF".hex == 0xFFFFFF)
        #expect("f3C".hex == 0xFF33CC)
        #expect("#ccc".hex == 0xCCCCCC)
        #expect("3".hex == 0x333333)
        #expect("".hex == 0x0)
    }

    @Test func hexInit() {
        #expect(String(hex: 0xFFFFFF) == "#FFFFFF")
        #expect(String(hex: 0xFF) == "#0000FF")
        #expect(String(hex: 0x0) == "#000000")
    }
}
