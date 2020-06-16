//
//  ErrorHandler.swift
//  Comuse
//
//  Created by 조현빈 on 2020/06/16.
//  Copyright © 2020 hyunbin. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialSnackbar

class ErrorHandler {
    public static func generateSnackBarWithAction(title: String, actionTitle: String, onAction: @escaping() -> Void) {
        let snackbar = MDCSnackbarMessage()
        snackbar.text = title
        let action = MDCSnackbarMessageAction()
        let actionHandler = {() in
            onAction()
        }
        action.handler = actionHandler
        action.title = actionTitle
        snackbar.action = action
    }
}
