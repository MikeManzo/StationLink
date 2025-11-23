//
//  RedirectHandler.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

// MARK: - URL Session Redirect Handler
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        // Don't follow redirects to custom URL schemes
        if let url = request.url?.absoluteString, url.starts(with: "com.scee.psxandroid.scecompcall://") {
            print("Intercepted redirect to: \(url)")
            completionHandler(nil) // Don't follow the redirect
        } else {
            completionHandler(request) // Follow normal redirects
        }
    }
}
