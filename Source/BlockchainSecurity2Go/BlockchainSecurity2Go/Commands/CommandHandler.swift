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

/// Contains the handlers to transmit APDU commands
class CommandHandler{
    var tag: NFCISO7816Tag
    var reader_session: NFCTagReaderSession
    
    /// Initialize the command handler with CoreNFC handles
    /// - Parameters:
    ///   - tag_iso7816: ISO7816 tag handle for communication with the tag
    ///   - reader_session: NFCTagReaderSession  handle for communication with the tag
    init(tag_iso7816: NFCISO7816Tag, reader_session: NFCTagReaderSession) {
        self.tag = tag_iso7816
        self.reader_session = reader_session
    }
    
    /// Transmits the command APDU to the NFC tag and returns the response on the response event handler
    /// - Parameters:
    ///   - command: Command APDU to be transmitted
    ///   - on_response_event: Response event handler that contains the response APDU
    func Transmit(command: APDUCommand, on_response_event: @escaping (APDUResponse) -> Void) {
        let command_apdu = NFCISO7816APDU(data: command.command)
        self.tag.sendCommand(apdu: command_apdu!) { (response: Data, sw1: UInt8, sw2: UInt8, error: Error?)
            in
            on_response_event(APDUResponse(sw1: sw1, sw2: sw2, data: response))
        }
    }
    
}
