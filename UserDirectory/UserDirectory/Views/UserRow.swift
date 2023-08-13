//
//  UserRow.swift
//  UserDirectory
//
//  Created by ali rahal on 11/08/2023.
//

import Foundation
import SwiftUI

struct UserRow: View {
    let user: UsersListViewModel.UsersDataLocal
    
    var body: some View {
        HStack() {
            AsyncImage(url: URL(string: user.imageURL ?? ""), content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding(8)
            }) {
                ProgressView()
                    .scaleEffect(2.0)
                    .frame(height: 100)
            }
            .padding(4)
            
            VStack(alignment: .leading,spacing: 4) {
                Spacer()
                Text(user.username ?? "")
                    .font(.title3)
                Text(user.email ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user.phoneNumber ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                HStack {
                    if user.cached == true {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 12, height: 12)
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.yellow, lineWidth: 1)
                            .frame(width: 50, height: 20)
                            .overlay(
                                Text("Cached")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Fill available width with text
            .padding(.vertical, 8) // Add vertical padding to align with image
        }
        .background(Color.clear) // Remove background color
    }
}

