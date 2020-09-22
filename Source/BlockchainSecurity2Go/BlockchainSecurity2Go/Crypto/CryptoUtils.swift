//
//  CryptoUtils.swift
//  BlockchainSecurity2Go
//
//  Created by Infineon on 17/09/20.
//  Copyright © 2020 Infineon Technologies. All rights reserved.
//

import Foundation

class CryptoUtils {
    
    
    static func StringToBytes(_ string: String) -> [UInt8]? {
        let string = string.replacingOccurrences(of: " ", with: "")
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    /*
    static func ComputeSHA3Hash() {
        var input: String = "9F2FCC7C90DE090D6B87CD7E9718C1EA6CB21118FC2D5DE9F97E5DB6AC1E9C10"
        var output: String = "2F1A5F7159E34EA19CDDC70EBF9B81F1A66DB40615D7EAD3CC1F1B954D82A3AF"
        
        var input2: String = "89 33 4A 74 4E 74 A7 F3 59 AE F7 70 1B D0 43 F8 5D 23 2D 43 ED 8B 4E E6 13 5C CF CF 4E 0D AB 9F AB 16 1E 21 B4 E3 1A 0A A6 99 29 BB E5 BD 0A 0E 06 66 68 30 58 54 1B 71 E1 0A EC EA D8 51 54 BA"
        var output2: String = "6E9FC0146CE10B6915A7915E41951819859A9C00"
        
        var input_bytes = StringToBytes(input)
        var output_bytes = StringToBytes(output)
        
        var input_bytes2 = StringToBytes(input2)
        var output_bytes2 = StringToBytes(output2)
        
        var input_length: Int = 0
             
        if(input_bytes != nil){
            input_length = input_bytes!.count
        }
        print(input_bytes)
        print(output_bytes)
        print(input_bytes2)
        print(output_bytes2)
        
        let digest : Data = SHA3.ComputeSHA3_256("hello".data(using: String.Encoding.utf8)!)
        if(digest.base64EncodedString() == "Mzi+aU9QxfM4gUmGzfBoZFOoiLhPQk15KvS5ICOY85I="){
            print("Matching-Success")
        }else{
            print("Not Matching-Failure")
        }
        
        let arrData2 = Data(input_bytes!)
        let outputData2 = Data(output_bytes!)
        let digest2 : Data = SHA3.ComputeSHA3_256(arrData2)
        if(digest2 == outputData2){
            print("Matching 2-Success")
        }else{
            print("Not Matching 2-Failure")
        }
     
        let arrData3 = Data(input_bytes2!)
        let outputData3 = Data(output_bytes2!)
        let digest3 : Data = SHA3.ComputeSHA3_256(arrData3)
        if(digest3 == outputData3){
            print("Matching 3-Success")
        }else{
            print("Not Matching 3-Failure")
        }
        print(digest3.hexEncodedString())
    }
 */
}
