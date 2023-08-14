# UserDirectoryApp
SwiftUI MVVM Demo Project using RandomUser API for fetching users. 

## Goal
User Directory App aims to develop a straightforward iOS app that presents a comprehensive list of random users.

## Features
1. Fetching Random Users
2. Pagination ( once the user reaches the end of the list new values will be fetched by incrementing offset and triggering an api request )
3. Network Monitering ( once the user gets offline an error will be shown and only cached values will be presented)
4. Caching and Offline Support ( cached results will be appeneded to newly fetched values and there is a visual indication in each user row )
5. Encryption and Decryption
6. Error Handling
7. Display Gender Distribution
8. Display Cached/New Distribution and clear cache for testing purposes 

## Architecture 
MVVM (Model-View-ViewModel) was chosen as the architecture for this app due to its benefits. It provides a clear separation of concerns between the Model, View, and ViewModel components. The architecture leverages data binding mechanisms to automatically update the UI when the Model changes, reducing manual synchronization.

Order of events : 
1. view model is responsible for communicating with network service
2. fetching results 
4. updating app state
5. content view will update UI based on app state

## API used
The app utilizes RandomUsers API for fetching users.

## Device Support
actual device advised - network monitoring creates some issues on simulator
