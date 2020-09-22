/*
MIT License

Copyright (c) 2020 Infineon Technologies AG

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Foundation

/// Stores the response APDU
class APDUResponse {
    public static let SW_SUCCESS: UInt16 = 0x9000;
    public static let SW_SUCCESS_WITH_RESPONSE: UInt8 = 0x61;
    public static let SW_KEY_WITH_IDX_NOT_AVAILABLE: UInt16 = 0x6A88;
    public static let SW_KEY_STORAGE_FULL: UInt16 = 0x6A84;
    
    var sw1: UInt8
    var sw2: UInt8
    var data: Data?
    
    /// Initializes the response APDU
    /// - Parameters:
    ///   - sw1: Response status word 1
    ///   - sw2: Response status word 2
    ///   - data: Response data without status word
    init(sw1: UInt8, sw2: UInt8, data: Data?)
    {
        self.sw1 = sw1
        self.sw2 = sw2
        self.data = data
    }
    
    /// Gets the combined status word - SW1 and SW2
    /// - Returns: Status word as 2 bytes / UINT16
    func GetSW() -> UInt16 {
        var sw: UInt16 = 0
        sw += UInt16(self.sw1) << 8
        sw += UInt16(self.sw2) << 0
        return sw
    }
    
    /// Gets the status word in hex format
    /// - Returns: Status word as hex string
    func GetSWHex() -> String {
        return String(format:"%02X", self.sw1) + String(format:"%02X", self.sw2)
    }
    
    /// Checks whether the status word indicates SUCCESS
    /// - Returns: Flag indicating success (true) or failure (false)
    func IsSuccessSW() -> Bool{
        return (self.GetSW() == APDUResponse.SW_SUCCESS ||
            self.sw1 == APDUResponse.SW_SUCCESS_WITH_RESPONSE)
    }
    
    /// Compares the response status word against the input status word
    /// - Parameter sw: Input status word to be compared
    /// - Returns: Flag indicating success (true) or failure (false)
    func CheckSW(sw: UInt16) -> Bool{
        return (self.GetSW() == sw)
    }
}
