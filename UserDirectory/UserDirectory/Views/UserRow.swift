//
//  UserRow.swift
//  UserDirectory
//
//  Created by ali rahal on 11/08/2023.
//

import Foundation
import SwiftUI

struct UserRow: View {
    let user: UsersListViewModel.UsersData
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top) {
                AsyncImage(url: URL(string: user.imageURL ?? ""), content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }) {
                    ProgressView()
                        .scaleEffect(2.0)
                        .frame(height: 100)
                        
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) { // Set alignment to .center
                    Text(user.username ?? "")
                        .font(.title)
                    Text(user.email ?? "")
                        .font(.caption)
                    Text(user.phoneNumber ?? "")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity) // Add maxWidth to expand the text horizontally
            }
        }
    }

}
