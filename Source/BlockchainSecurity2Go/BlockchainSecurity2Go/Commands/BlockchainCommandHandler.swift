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
import CoreNFC

/** Manages to APDU exchange for reading the public-key from the Blockchain Seurity2Go card
    1) SELECT_APPLICATION
    2) GET_KEY_INFO
    3) If key not available at index, GENERATE_KEY multiple times until selected key index is generated and then GET_KEY_INFO
*/
class BlockchainCommandHandler: CommandHandler {
    let TAG: String = "BlockchainCommandHandler"

    // Command APDU definitions
    let APDU_SELECT = Data(_: [0x00,0xA4,0x04,0x00,0x0D,0xD2,0x76,0x00,0x00,0x04,0x15,
                               0x02,0x00,0x01,0x00,0x00,0x00,0x01,0x00])
    let ADPU_GET_KEY_INFO = Data(_: [0x00,0x16,0x00,0x00,0x00])
    let ADPU_GENERATE_KEY = Data(_: [0x00,0x02,0x00,0x00,0x01])
    
    /// Action completion handler, which is called when the command excahges are completed
    var OnActionCompleted: ((Bool, Data?, String?, NFCTagReaderSession) -> ())?
    var key_index: UInt8 = 0x01
    
    /// Triggers the APDU exchanges to get the public-key from the card
    /// - Parameters:
    ///   - key_index: Key index of the public-key. Must be >0.
    ///   - completion_handler: Handler method to be called when the action is completed
    func ActionGetKey(key_index: UInt8, completion_handler: @escaping (Bool, Data?,String?,NFCTagReaderSession) -> Void) {
        self.key_index = key_index
        self.OnActionCompleted = completion_handler
        
        SelectApplication()
    }
    
    // MARK: - Command handler - SELECT_APPLICATION
    /// Sends the SELCT_APPLICATION command to the card
    private func SelectApplication() {
        Utils.Log(TAG, "Transmit: SELECT_APPLICATION")
        let apdu = APDUCommand(command: APDU_SELECT)
        Transmit(command: apdu, on_response_event: OnSelectApplicationCompleted)
    }
    
    /// Handles the response of the SELECT_APPLICATION command. When successful, it sends the next command to get the key
    /// - Parameter response: Response of SELECT_APPLICATION
    private func OnSelectApplicationCompleted(response: APDUResponse) {
        if(!response.IsSuccessSW()) {
            Utils.Log(TAG, "Response: SELECT_APPLICATION Failed: " + response.GetSWHex())
            OnActionCompleted?(false, nil, "SELECT_APP SW: " + response.GetSWHex(), reader_session)
            return
        }
        Utils.Log(TAG, "Response: SELECT_APPLICATION Success")
        
        // Application selected, Read the public-key from the card
        GetKeyInfo()
    }
    
    // MARK: - Command handler - GET_KEY_INFO
    /// Frames the GET_KEY_INFO command with the key index
    /// - Returns: GET_KEY_INFO command
    private func GetKeyInfoCommand() -> Data {
        var command = ADPU_GET_KEY_INFO
        command[2] = key_index
        return command
    }
    
    /// Sends the GET_KEY_INFO command to the card
    private func GetKeyInfo() {
        Utils.Log(TAG, "Transmit: GET_KEY_INFO")
        let apdu = APDUCommand(command: GetKeyInfoCommand())
        Transmit(command: apdu, on_response_event: OnGetKeyInfoCompleted)
    }
    
    /// Handles the response of the GET_KEY_INFO command. When successful, completes the action. When failed, it generates the key
    /// - Parameter response: Response of GET_KEY_INFO
    private func OnGetKeyInfoCompleted(response: APDUResponse) {
        if(response.IsSuccessSW()) {
             Utils.Log(TAG, "Response: GET_KEY_INFO Success")
            
            // Complete the action
            OnActionCompleted?(true, response.data, nil, reader_session)
        }else{
             Utils.Log(TAG, "Response: GET_KEY_INFO Failed: " + response.GetSWHex())
            
            // When selected key index is not available, generate new key pair
            if(response.CheckSW(sw: APDUResponse.SW_KEY_WITH_IDX_NOT_AVAILABLE)) {
                GenerateNewSecp256K1Keypair()
            } else {
                OnActionCompleted?(false, nil, "GET_KEY_INFO SW: " + response.GetSWHex(), reader_session)
            }
        }
    }
    
    // MARK: - Command handler - GENERATE_KEY
    /// Sends the GENERATE_KEY command to the card
    private func GenerateNewSecp256K1Keypair() {
        Utils.Log(TAG, "Transmit: GENERATE_KEY")
        let apdu = APDUCommand(command: ADPU_GENERATE_KEY)
        Transmit(command: apdu, on_response_event: OnGenerateNewSecp256K1KeypairCompleted)
    }
    
    /// Handles the response of the GENERATE_KEY command. When failed, it completes the action.
    /// When successful, it checks if the required key-index is available and generates key again if required.
    /// If the required key index is populated, it reads the public key.
    /// - Parameter response: Response of GENERATE_KEY command
    private func OnGenerateNewSecp256K1KeypairCompleted(response: APDUResponse) {
        if(response.IsSuccessSW()) {
            // Response data contains the generated key index
            if(response.data?.count != 1) {
                 Utils.Log(TAG, "GENERATE_KEY invalid response - Doesnt have generated key index")
                OnActionCompleted?(false, nil, "Invalid GENERATE_KEY response", reader_session)
            } else{
                Utils.Log(TAG, "Response: GENERATE_KEY Success")
                
                // Newly genrated key's index
                let new_key_index = response.data![0]
                if(new_key_index < key_index) {
                    Utils.Log(TAG, "Required key index not generated yet. Generating keypair again.")
                    GenerateNewSecp256K1Keypair()
                }
                else {
                    Utils.Log(TAG, "Required key index is generated. Reading the public-key.")
                    GetKeyInfo()
                }
            }
        } else {
            Utils.Log(TAG, "Response: GENERATE_KEY Failed: " + response.GetSWHex())
            
            if(response.CheckSW(sw: APDUResponse.SW_KEY_STORAGE_FULL)) {
                Utils.Log(TAG, "Key storage is full")
                OnActionCompleted?(false, nil, "Key storage is full", reader_session)
            } else {
                OnActionCompleted?(false, nil, "GENERATE_KEY SW: " + response.GetSWHex(), reader_session)
            }
        }
    }
}
