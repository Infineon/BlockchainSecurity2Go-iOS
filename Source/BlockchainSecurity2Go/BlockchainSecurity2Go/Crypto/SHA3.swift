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

/// Wrapper around the libkeccak-tiny library for computing SHA3 hash
class SHA3 {
    
    /// Computes the SHA3 hash with libkeccak-tiny
    /// - Parameter data: Input data to compute hash
    /// - Returns: SHA3 hash of 32 bytes
    public static func ComputeSHA3_256(_ data: Data) throws -> Data {
        let nsData = data as NSData
        let input = nsData.bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 32)
        sha3_256(result, 32, input, data.count)
        return Data(bytes: result, count: 32)
    }
}
