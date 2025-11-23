//
//  NoDataView.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI

struct NoDataView: View {
    let errorMessage: String?
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "playstation.logo")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No PlayStation Data")
                .font(.headline)
            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}
