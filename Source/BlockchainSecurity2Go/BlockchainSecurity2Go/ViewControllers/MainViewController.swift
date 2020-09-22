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

import UIKit
import CoreNFC

/// Contains the user interface controller code of the main screen
class MainViewController: UIViewController {
    let TAG: String = "MainViewController"
    
    @IBOutlet weak var img_qrcode: UIImageView!
    @IBOutlet weak var imgbtn_options: UIImageView!
    @IBOutlet weak var lbl_ethereum_address: UILabel!
    @IBOutlet weak var lbl_status: UILabel!
    @IBOutlet weak var seg_keyindex: UISegmentedControl!
    
    var nfc_helper: NFCHelper?
    
    /// Stores the key index selected by the user. Default value is 1
    var selected_keyindex: UInt8  = 0x01
    
    // MARK: - View controller events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigureViews()
        ResetDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Event handlers
    /// Event handler function to handle long press gesture
    @objc func AddressLabelLongPressed(sender: UILongPressGestureRecognizer) {
        if(sender.state == .began) {
            Utils.Log(TAG, "Address label long pressed")
            CopyAddressToClipboard()
        }
    }
    
    /// Event handler function to handle tap gesture
    @objc func OptionsIconTapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            Utils.Log(TAG, "Options icon is tapped")
            DisplayAboutScreen()
        }
    }
    
    /// Button click handler of the read tag button
    @IBAction func ReadCardButtonClick(_ sender: Any) {
        Utils.Log(TAG, "Read card button clicked")
        
        ResetDefaults()
        selected_keyindex = GetSelectedKeyIndexFromUI()
        BeginNFCReadSession()
    }
    
    // MARK: - Private helpers: UI
    /// Configures the user interface elements and assigns the respective event handlers
    func ConfigureViews(){
        // Set the interface style to dark mode
        overrideUserInterfaceStyle = .dark
        
        // Set the segmented control's appearance
        let seg_font = UIFont.systemFont(ofSize: 20)
        seg_keyindex.setTitleTextAttributes([NSAttributedString.Key.font: seg_font], for: .normal)
        // Segmented control selected text color
        seg_keyindex.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // Segmented control default text color
        seg_keyindex.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        // Assign long press gesture handler for address label
        let lbl_copy_gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.AddressLabelLongPressed))
        lbl_ethereum_address.addGestureRecognizer(lbl_copy_gesture)
        lbl_ethereum_address.isUserInteractionEnabled = true
        
        // Assign tap gesture handler for options(...) icon
        let options_tap_gesture = UITapGestureRecognizer(target: self, action: #selector(MainViewController.OptionsIconTapped))
        imgbtn_options.addGestureRecognizer(options_tap_gesture)
        imgbtn_options.isUserInteractionEnabled = true
    }
    
    /// Resets the user interface elements to the initial state
    func ResetDefaults() {
        self.lbl_ethereum_address.text = ""
        self.lbl_status.text = NSLocalizedString("starter_kit", comment: "Initial title to be displayed")
        self.img_qrcode.image = UIImage(named: "css-blockchain-icon")?.alpha(0.2)
    }
    
    /// Pushes the about screen to the navigation stack
    func DisplayAboutScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "AboutViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Copies the ethereum address to the clipboard and displays an alert to the user
    func CopyAddressToClipboard(){
        let text_to_copy = lbl_ethereum_address.text
        if(text_to_copy != ""){
            // Copy text to clipboard
            UIPasteboard.general.string = text_to_copy
            Utils.Log(TAG, "Copied address to clipboard")
            
            // Display an information alert
            let alert = UIAlertController(
                title: NSLocalizedString("copied_title", comment: "Title of the alert dialog"),
                message: NSLocalizedString("copied_message", comment: "Message after the text is copied"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("ok", comment: "OK"),
                style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Gets the user selected key index from the UI element
    /// - Returns: Key index value
    func GetSelectedKeyIndexFromUI() -> UInt8 {
        var index: Int = self.seg_keyindex.selectedSegmentIndex
        index = index + 1
        return UInt8(index & 0xff)
    }
    
    /// Creates the QR code based on input and displays in the UI
    /// - Parameter data: Input for the QR code
    func SetQRCode(data: String) {
        let img_qrcode: UIImage? = Utils.GenerateQRCode(from: data)
        if (img_qrcode != nil) {
            self.img_qrcode.image = img_qrcode
        }
    }
    
    /// Displays the ethereum address in QR code format and in text. Also displays the timestamp.
    /// - Parameter address: Ethererum address to be displayed
    func DisplayEthereumAddress(address: Data){
        let prefix: String = "0x"
        self.lbl_ethereum_address.text = prefix + address.hexEncodedString(space_required: false)
        self.SetQRCode(data: prefix + address.hexEncodedString(space_required: false))
        self.lbl_status.text = NSLocalizedString("timestamp_prefix", comment: "Card scanned on ") +
            Utils.GetTimestamp()
    }
    
    // MARK: - Private helpers: NFC
    /// Checks for NFC support and begins a tag reader session
    func BeginNFCReadSession() {
        
        // Check whether NFC is supported in this device
        guard NFCNDEFReaderSession.readingAvailable else {
            Utils.Log(TAG, "Device doesn't support NFC")
            
            let alert = UIAlertController(
                title: NSLocalizedString("no_nfc_title", comment: "Title for No-NFC alert"),
                message: NSLocalizedString("no_nfc_message", comment: "Message for No-NFC alert"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("ok", comment: "OK"),
                style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // Begin the NFC reader session
        nfc_helper = NFCHelper()
        nfc_helper?.OnTagEvent = self.OnTagEvent(success:tag:session:error:)
        nfc_helper?.BeginSession()
    }
    
    /// Handles the initial tag events such as tag presented, timeout, etc. of the NFCHelper class
    /// - Parameters:
    ///   - success: Indicates whether the tag is detected successfully
    ///   - tag: ISO7816 tag handle for further communication with the tag. nil if tag not detected.
    ///   - session: NFCTagReaderSession handle for further communication with the tag. nil if tag not detected.
    ///   - error: Error description in case of tag detection failure
    func OnTagEvent(success: Bool, tag: NFCISO7816Tag?,
                    session: NFCTagReaderSession?, error: String?) {
        if(success){
            // If the tag reader session handle is available, start sending the commands
            if(tag != nil && session != nil){
                SendBlockchainCommand(tag: tag!, session: session!)
            }
        }
        else {
            // Failed to detect tag. Display failure
            var error_message: String = NSLocalizedString("detect_failure", comment: "Failed to detect tag. ")
            if(error != nil) {
                error_message += error!
            }
            DispatchQueue.main.async {
                self.img_qrcode.image = UIImage(named: "warning-icon")
                self.lbl_status.text =  error_message
            }
        }
    }
    
    /// Exchanges Blockchain commands to read the public key from the tag
    /// - Parameters:
    ///   - tag: ISO7816 tag handle for communication with the tag
    ///   - session: NFCTagReaderSession handle for communication with the tag
    func SendBlockchainCommand(tag: NFCISO7816Tag, session: NFCTagReaderSession)
    {
        let command_handler: BlockchainCommandHandler = BlockchainCommandHandler(tag_iso7816: tag, reader_session: session)
        command_handler.ActionGetKey(key_index: selected_keyindex, completion_handler: OnCommandCompleted)
    }
    
    /// Handles the action completed event for BlockchainCommandHandler. This processes the result of the APDU exchanges.
    /// - Parameters:
    ///   - success: Indicates whether the GetKey action is completed successfully
    ///   - response: APDU response of GetKey command without SW
    ///   - session: NFCTagReaderSession handle for invalidating the session
    /// - Returns: Nothing
    func OnCommandCompleted(success: Bool, response: Data?, error: String?, session: NFCTagReaderSession) -> Void{
        
        var result: Bool = false
        var error_msg: String = ""
        if(error != nil) {
            error_msg = error!
        }
        
        if(success && (response != nil)){
            Utils.Log(TAG, "Response from card: " + response!.hexEncodedString())
            
            let public_key = Utils.ExtractPublicKey(get_key_response: response!)
            if(public_key != nil) {
                let ethereum_address = Utils.GetEthereumAddress(public_key: public_key!)
                if(ethereum_address != nil) {
                    result = true
                    // Display the result
                    DispatchQueue.main.async {
                        self.DisplayEthereumAddress(address: ethereum_address!)
                    }
                    Utils.Log(TAG, "Success: Ethereum address displayed")
                } else {
                    error_msg = NSLocalizedString("address_compute_failure", comment: "Failed to compute address")
                    Utils.Log(TAG, "Failed to compute ethereum address from public-key")
                }
            } else {
                error_msg = NSLocalizedString("key_parse_failure", comment: "Failed to parse key")
                Utils.Log(TAG, "Could not extract the public-key from response")
            }
        }

        if(result)
        {
            // Success
            session.alertMessage = NSLocalizedString("read_success", comment: "Completed successfully")
            session.invalidate()
        } else {
            
            DispatchQueue.main.async {
                self.img_qrcode.image = UIImage(named: "warning-icon")
                self.lbl_status.text = NSLocalizedString("read_failure", comment: "Failed to read tag. ") +
                    error_msg
            }
             session.invalidate(errorMessage: NSLocalizedString("read_failure", comment: "Failed to read tag. "))
        }
    }
}
