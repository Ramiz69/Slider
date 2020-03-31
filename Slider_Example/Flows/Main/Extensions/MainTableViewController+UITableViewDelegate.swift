//
//  MainTableViewController+UITableViewDelegate.swift
//  Slider_Example
//
//  Created by Рамиз Кичибеков on 31.03.2020.
//  Copyright © 2020 Ramiz Kichibekov. All rights reserved.
//

import UIKit

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case .zero:
            let identifier = String(describing: ViewController.self)
            guard
                let `storyboard` = storyboard,
                let controller = storyboard.instantiateViewController(identifier: identifier) as? ViewController
                else {
                    return
            }
            
            navigationController?.pushViewController(controller, animated: true)
        case 1:
            let codeController = CodeViewController()
            navigationController?.pushViewController(codeController, animated: true)
        default: break
        }
    }
    
}
