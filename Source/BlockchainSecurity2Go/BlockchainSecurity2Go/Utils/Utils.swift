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
import UIKit

/// Contains the utility methods
class Utils {
    // MARK: - Utility methods
    /// Generates QR code from the input string
    /// - Parameter string: Input data
    /// - Returns: QR code as UIImage. nil if failed to generate.
    static func GenerateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            // To scale the image to large size
            let transform = CGAffineTransform(scaleX: 8, y: 8)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    /// Extracts the public key from the GET_KEY_INFO command response
    /// - Parameter get_key_response: Response of the GET_KEY_INFO command without SW
    /// - Returns: Public-key of 64 bytes. Nil if unable to extract
    static func ExtractPublicKey(get_key_response: Data) -> Data? {
        // GET_KEY_INFO Response:
        // 04 bytes      Global signature counter
        // 04 bytes      Signature counter
        // 65 bytes      Public-key
        // 73 bytes  <-- Total
        
        // Public-key part:
        // 01 byte      Uncompressed - Value: 0x04
        // 32 bytes     x-coordinate
        // 32 bytes     y-coordinate
        
        let req_response_len = 73
        // At the moment we only support uncompressed keys (0x04)
        if (get_key_response.count < req_response_len || get_key_response[8] != 0x04) {
            // Invalid key response (or) unsupported key
            return nil
        }
        // Extracting only x,y coordinates (64 bytes)
        // 8 bytes (Counters) + 1 byte (Uncompressed-Indicator) = 9 bytes
        return get_key_response.subdata(in: 9..<req_response_len)
    }
    
    /// Computes the ethereum address from the public key.
    ///  1) Compute SHA3 hash for the public key
    ///  2) Extract the last 20 bytes of the hash
    /// - Parameter public_key: Public-key of 64 bytes
    /// - Returns: Ethereum address of 20 bytes. Nil if failed to compute
    static func GetEthereumAddress(public_key: Data) -> Data? {
        do {
            let hash: Data = try SHA3.ComputeSHA3_256(public_key)
            if(hash.count >= 32) {
                // Extract last 20 bytes from the hash
                let ethereum_address = hash.subdata(in: hash.count-20..<hash.count)
                return ethereum_address
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    /// Opens the URL on other applications that supports URL handling
    /// - Parameter url: URL to be opened
    static func OpenURL(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /// Generates the current timestamp and retuns as string
    /// - Returns: Date time as localized string
    static func GetTimestamp() -> String {
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        return timestamp
    }
    
    /// Prints the message in the console output for debug
    /// - Parameters:
    ///   - tag: Tag under which the message is logged. Eg.Classname, Module
    ///   - message: Message to be logged
    static func Log(_ tag: String, _ message: String){
        print(tag + ":\t" + message)
    }
}

// MARK: - Extensions
/// Initializes UIColor from hex color input
extension UIColor {
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
/// Extends the UIImage to support opacity
extension UIImage {
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension Data {
    /// Converts the byte array into hex encoded string
    /// - Parameter space_required: Optional flag indicating whether a space is required between the bytes
    /// - Returns: Hex encoded string
    func hexEncodedString(space_required: Bool = true) -> String {
        return map { String(format: "%02X" + (space_required ? " ":""), $0) }.joined()
    }
}
