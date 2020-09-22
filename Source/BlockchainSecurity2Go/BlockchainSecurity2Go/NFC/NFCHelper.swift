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

/// Helper class that manages the NFC card detection events
class NFCHelper: NSObject, NFCTagReaderSessionDelegate {
    let TAG: String = "NFCHelper"
    
    /// Stores the reader session handle
    var reader_session: NFCTagReaderSession?
    /// Event handler which is called when the tag detection action is completed
    var OnTagEvent: ((Bool, NFCISO7816Tag?, NFCTagReaderSession?, String?) -> ())?
    
    // MARK: - NFC Reader Session Events
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        Utils.Log(TAG, "ReaderSession: Active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Utils.Log(TAG, "ReaderSession: Invalidated")
        
        guard let OnTagEvent = OnTagEvent else {
            return
        }
        
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                // Indicate the tag operation event that it action failed
                OnTagEvent(false, nil, nil, error.localizedDescription)
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Utils.Log(TAG, "ReaderSession: Tag detected")
        
        guard let OnTagEvent = OnTagEvent else {
            return
        }
        
        if tags.count > 1 {
            Utils.Log(TAG, "ReaderSession: Multiple tags found")
            session.alertMessage = NSLocalizedString("err_multiple_tags", comment: "Multiple tags found")
            OnTagEvent(false, nil, nil, "Multiple tags found");
            EndSession()
            return
        }
        
        if case let NFCTag.iso7816(tag) = tags.first! {
            session.connect(to: tags.first!) { (error: Error?) in
                // Trigger the tag operation event
                OnTagEvent(true, tag, session, nil);
            }
        }
    }
    
    // MARK: - Helper methods
    /// Checks if the NFC reader is supported by this device
    /// - Returns: Flag indicating true if NFC reader is supported
    func IsNFCReaderAvailable() -> Bool{
        return NFCTagReaderSession.readingAvailable
    }
    
    /// Begins the ISO14443 reader session
    func BeginSession() {
        // Check if device supports NFC reading
        if(IsNFCReaderAvailable() == false) {
            return;
        }
        
        reader_session = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
        reader_session?.alertMessage = NSLocalizedString("tag_scan_prompt", comment: "Scan your NFC tag")
        reader_session?.begin()
        
        Utils.Log(TAG, "ReaderSession: Begin")
    }
    
    /// Invalidates the NFC reader session
    func EndSession(){
        reader_session?.invalidate()
        reader_session = nil
        
        Utils.Log(TAG, "ReaderSession: End")
    }
}
