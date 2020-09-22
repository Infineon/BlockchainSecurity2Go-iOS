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

/// Contains the user interface controller code for the about screen
class AboutViewController: UIViewController {
    let TAG: String = "AboutViewController"
    
    let ROW_HEIGHT: CGFloat = 50
    let CONTENT_VIEW_COLOR = 0x9C8D8F
    
    @IBOutlet weak var lbl_app_name: UILabel!
    @IBOutlet weak var lbl_app_Version: UILabel!
    @IBOutlet weak var tbl_links: UITableView!
    
    /// Contains the list of sections to be displayed in the tableview
    let link_sections = [NSLocalizedString("link_section_blockchain", comment: ""),
                         NSLocalizedString("link_section_infineon", comment: "")]
    
    /// Contains the arrays of links and their titles to be displayed for each section
    let links:[[(title: String, link: String)]] = [
        [(title: NSLocalizedString("link_ifx_blockchain", comment: ""), link: "https://www.infineon.com/blockchain"),
         (title: NSLocalizedString("link_git_blockchain", comment: ""), link: "https://github.com/Infineon/Blockchain"),
         (title: NSLocalizedString("link_git_blockchain_android", comment: ""), link: "https://github.com/Infineon/BlockchainSecurity2Go-Android"),
         (title: NSLocalizedString("link_git_blockchain_ios", comment: ""), link: "https://github.com/Infineon/BlockchainSecurity2Go-iOS"),
         (title: NSLocalizedString("link_git_blockchain_python", comment: ""), link: "https://github.com/Infineon/BlockchainSecurity2Go-Python-Library")],
        [(title: NSLocalizedString("link_ifx_web", comment: ""), link: "https://www.infineon.com"),
         (title: NSLocalizedString("link_ifx_facebook", comment: ""), link: "https://www.facebook.com/Infineon"),
         (title: NSLocalizedString("link_ifx_twitter", comment: ""), link: "https://twitter.com/Infineon")]]
    
    // MARK: - View controller events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigureViews()
    }
    
    // MARK: - Private helpers: UI
    /// Configures the user interface elements and assigns the respective event handlers
    func ConfigureViews(){
        // Set the interface style to dark mode
        overrideUserInterfaceStyle = .dark
        
        // Delegate and datasources are implemented as extensions
        tbl_links.delegate = self
        tbl_links.dataSource = self
        // Hide the extra footer space in tableview control
        tbl_links.tableFooterView = UIView()
        
        // Display the app name and version
        lbl_app_name.text = NSLocalizedString("app_name_full", comment: "Full name of the app")
        lbl_app_Version.text = Bundle.main.version_string
    }
}

// MARK: - Extensions
extension Bundle {
    
    /// Returns the version number from the info.plist file
    var version_number: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    /// Returns the build number from the info.plist file
    var build_version_number: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    /// Returns a formatted string combining the version number and build number
    var version_string: String {
        return ("Version " + (version_number ?? "0.0.0") + " Build " + (build_version_number ?? "000000"))
    }
}

/// Tableview click handler extension
extension AboutViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Utils.Log(TAG, "Link is clicked")
        
        // Open the selected link
        let link_url = links[indexPath.section][indexPath.row].link
        Utils.OpenURL(url: link_url)
    }
}

/// Tableview data source provider extension
extension AboutViewController: UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        // Total number of sections
        return links.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section <= link_sections.count {
            // Returns the section header
            return link_sections[section]
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Total number of links under the section
        return links[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Populate the link title on the required row
        let link_text = links[indexPath.section][indexPath.row].title
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LinkTableViewCell
        cell.cell_title.text = link_text
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(hex: CONTENT_VIEW_COLOR)
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }
}

// MARK: - Additional classes
class LinkTableViewCell: UITableViewCell{
    @IBOutlet weak var cell_title: UILabel!
}
