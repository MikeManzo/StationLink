//
//  PlayStationService.swift
//  StationLink
//
//  Created by Mike Manzo on 11/23/25.
//

import SwiftUI
import Combine
import UserNotifications

class PlayStationService: ObservableObject {
    @Published var user: PSNUser?
    @Published var presence: PSNPresence?
    @Published var friends: [Friend] = []
    @Published var recentGames: [GameTitle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var trophyTitleMap: [String: (npCommunicationId: String, npServiceName: String)] = [:]
    private var npsso: String = ""
    private var accessToken: String?
    private var refreshToken: String?
    private var tokenExpiresAt: Date?
    private var capturedRedirectURL: String?
    private var previousFriendStatuses: [String: String] = [:] // Track previous online status
    private var refreshTimer: Timer?
    private var autoRefreshInterval: TimeInterval = 60 // Refresh every 60 seconds
    
    func startAutoRefresh() {
        // Stop any existing timer
        stopAutoRefresh()
        
        // Create a new timer that fires every minute
        refreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                print("🔄 Auto-refreshing friend status...")
                await self.refreshAllFriends()
            }
        }
        
        print("✓ Auto-refresh started (every \(Int(autoRefreshInterval)) seconds)")
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func setNPSSO(_ token: String) {
        self.npsso = token.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(self.npsso, forKey: "npsso")
    }
    
    func loadStoredCredentials() {
        if let stored = UserDefaults.standard.string(forKey: "npsso") {
            self.npsso = stored
        }
        if let storedAccessToken = UserDefaults.standard.string(forKey: "access_token"),
           let storedRefreshToken = UserDefaults.standard.string(forKey: "refresh_token"),
           let storedExpiry = UserDefaults.standard.object(forKey: "token_expiry") as? Date {
            self.accessToken = storedAccessToken
            self.refreshToken = storedRefreshToken
            self.tokenExpiresAt = storedExpiry
        }
        loadFriends()
    }
    
    func saveTokens(access: String, refresh: String, expiresIn: Int) {
        self.accessToken = access
        self.refreshToken = refresh
        self.tokenExpiresAt = Date().addingTimeInterval(TimeInterval(expiresIn))
        
        UserDefaults.standard.set(access, forKey: "access_token")
        UserDefaults.standard.set(refresh, forKey: "refresh_token")
        UserDefaults.standard.set(tokenExpiresAt, forKey: "token_expiry")
    }
    
    func clearStoredTokens() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "token_expiry")
        accessToken = nil
        refreshToken = nil
        tokenExpiresAt = nil
    }
    
    func loadFriends() {
        if let data = UserDefaults.standard.data(forKey: "friends"),
           let decoded = try? JSONDecoder().decode([Friend].self, from: data) {
            friends = decoded
        }
    }
    
    func saveFriends() {
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: "friends")
        }
    }
    
    func addFriend(onlineId: String, accountId: String, isImported: Bool = false) async {
        guard !friends.contains(where: { $0.accountId == accountId }) else {
            print("Friend already added")
            return
        }
        
        let friend = Friend(onlineId: onlineId, accountId: accountId, isImported: isImported)
        await MainActor.run {
            friends.append(friend)
            saveFriends()
            print("✓ Added friend: \(onlineId)")
        }
        
        // Fetch full profile and presence data
        await fetchFriendData(onlineId: onlineId)
    }
    
    func removeFriend(_ onlineId: String) {
        friends.removeAll { $0.id == onlineId }
        saveFriends()
    }
    
    func searchUser(username: String) async -> FriendSearchResult? {
        guard let token = accessToken else { return nil }
        
        guard let url = URL(string: "https://us-prof.np.community.playstation.net/userProfile/v1/users/\(username)/profile2?fields=onlineId,accountId,avatarUrls") else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Search Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    return nil
                }
            }
            
            if let json = try? JSONDecoder().decode([String: FriendSearchResult].self, from: data),
               let result = json["profile"] {
                return result
            }
            
            return nil
        } catch {
            print("Search error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func authenticate() async {
        guard !npsso.isEmpty else {
            await MainActor.run {
                errorMessage = "NPSSO token required"
            }
            return
        }
        
        await MainActor.run { isLoading = true }
        
        // Check if we have valid tokens and can use refresh token
        if let token = accessToken,
           let expiry = tokenExpiresAt,
           expiry > Date().addingTimeInterval(300) {
            print("✓ Using existing valid token")
            await fetchUserProfile()
            return
        }
        
        // If token is expired but we have refresh token, use it
        if let refresh = refreshToken {
            print("→ Refreshing expired token...")
            await refreshAccessToken(refresh)
            return
        }
        
        // Otherwise, do full NPSSO authentication
        print("→ Starting NPSSO authentication...")
        await authenticateWithNPSSO()
    }
    
    func authenticateWithNPSSO() async {
        // Step 1: Exchange NPSSO for access code
        guard let url = URL(string: "https://ca.account.sony.com/api/authz/v3/oauth/authorize?access_type=offline&client_id=09515159-7237-4370-9b40-3806e67c0891&redirect_uri=com.scee.psxandroid.scecompcall://redirect&response_type=code&scope=psn:mobile.v2.core%20psn:clientapp") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("npsso=\(npsso)", forHTTPHeaderField: "Cookie")
        
        // Create a custom URLSession that doesn't follow redirects
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Access Code Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 429 {
                    await MainActor.run {
                        errorMessage = "Rate limited. Your IP has been temporarily blocked.\n\nSolutions:\n1. Wait 30-60 minutes\n2. Use a VPN\n3. Use a different network"
                        isLoading = false
                    }
                    return
                }
                
                // Check for redirect in Location header
                if let location = httpResponse.value(forHTTPHeaderField: "Location") {
                    print("Redirect Location: \(location)")
                    capturedRedirectURL = location
                }
            }
            
            // Parse code from captured redirect URL
            var code: String?
            
            if let redirectUrl = capturedRedirectURL,
               let components = URLComponents(string: redirectUrl),
               let codeParam = components.queryItems?.first(where: { $0.name == "code" })?.value {
                code = codeParam
                print("✓ Got access code from redirect: \(code!.prefix(10))...")
            }
            
            // Fallback: Try parsing from JSON response
            if code == nil {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response body: \(jsonString)")
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let redirectUrl = json["redirect_uri"] as? String,
                       let components = URLComponents(string: redirectUrl),
                       let codeParam = components.queryItems?.first(where: { $0.name == "code" })?.value {
                        code = codeParam
                        print("✓ Got access code from JSON: \(code!.prefix(10))...")
                    }
                }
            }
            
            guard let finalCode = code else {
                await MainActor.run {
                    errorMessage = "Failed to extract access code.\nCheck console for details."
                    isLoading = false
                }
                return
            }
            
            // Step 2: Exchange code for tokens
            await exchangeCodeForTokens(finalCode)
            
        } catch {
            await MainActor.run {
                errorMessage = "Network error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func exchangeCodeForTokens(_ code: String) async {
        guard let url = URL(string: "https://ca.account.sony.com/api/authz/v3/oauth/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Use the correct Basic Auth header from PSNAWP library
        request.setValue("Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A=", forHTTPHeaderField: "Authorization")
        
        let body = "code=\(code)&redirect_uri=com.scee.psxandroid.scecompcall://redirect&grant_type=authorization_code&token_format=jwt"
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Token Exchange Status: \(httpResponse.statusCode)")
            }
            
            let decoder = JSONDecoder()
            if let tokens = try? decoder.decode(AuthTokens.self, from: data) {
                print("✓ Got access & refresh tokens")
                saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken, expiresIn: tokens.expiresIn)
                await fetchUserProfile()
            } else {
                await MainActor.run {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Token Response: \(jsonString)")
                    }
                    errorMessage = "Failed to exchange code for tokens"
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Token exchange error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func refreshAccessToken(_ refresh: String) async {
        guard let url = URL(string: "https://ca.account.sony.com/api/authz/v3/oauth/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Use the correct Basic Auth header
        request.setValue("Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A=", forHTTPHeaderField: "Authorization")
        
        let body = "refresh_token=\(refresh)&grant_type=refresh_token&token_format=jwt&scope=psn:mobile.v2.core%20psn:clientapp"
        request.httpBody = body.data(using: .utf8)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let decoder = JSONDecoder()
            if let tokens = try? decoder.decode(AuthTokens.self, from: data) {
                print("✓ Refreshed tokens")
                saveTokens(access: tokens.accessToken, refresh: tokens.refreshToken, expiresIn: tokens.expiresIn)
                await fetchUserProfile()
            } else {
                // Refresh failed, clear tokens and retry with NPSSO
                print("⚠ Refresh failed, re-authenticating with NPSSO")
                clearStoredTokens()
                await authenticateWithNPSSO()
            }
        } catch {
            await MainActor.run {
                errorMessage = "Refresh error: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    func fetchUserProfile() async {
        guard let token = accessToken else { return }
        
        // Get basic profile and detailed trophy summary
        guard let url = URL(string: "https://us-prof.np.community.playstation.net/userProfile/v1/users/me/profile2?fields=onlineId,accountId,avatarUrls,aboutMe,trophySummary(@default,progress,earnedTrophies)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Profile Status: \(httpResponse.statusCode)")
            }
            
            if let json = try? JSONDecoder().decode([String: PSNUser].self, from: data),
               let profile = json["profile"] {
                await MainActor.run {
                    user = profile
                    print("✓ Loaded profile: \(profile.onlineId)")
                }
            } else {
                print("⚠ Failed to parse profile JSON")
                await MainActor.run {
                    errorMessage = "Failed to parse profile data"
                    isLoading = false
                }
                return
            }
            
            await fetchPresence()
            await refreshAllFriends()
            
            // Fetch trophy titles first to get npCommunicationIds
            trophyTitleMap = await fetchUserTrophyTitles()
            
            await fetchRecentGames()
            await importPSNFriends()
            
            // Start auto-refresh after successful authentication
            await MainActor.run {
                startAutoRefresh()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func fetchPresence() async {
        guard let token = accessToken,
              let accountId = user?.accountId else {
            print("⚠ Missing token or accountId for presence")
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        // Try the basic presence endpoint first
        guard let url = URL(string: "https://m.np.playstation.com/api/userProfile/v1/internal/users/\(accountId)/basicPresences?type=primary") else {
            await MainActor.run {
                isLoading = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Presence Status: \(httpResponse.statusCode)")
            }
            
            // Try parsing as an object with basicPresence key
            if let json = try? JSONDecoder().decode([String: PSNPresence].self, from: data),
               let presenceData = json["basicPresence"] {
                await MainActor.run {
                    presence = presenceData
                    isLoading = false
                    print("✓ Loaded presence: \(presenceData.onlineStatus)")
                }
            } else if let json = try? JSONDecoder().decode([String: [PSNPresence]].self, from: data),
                      let presences = json["basicPresences"],
                      let presenceData = presences.first {
                await MainActor.run {
                    presence = presenceData
                    isLoading = false
                    print("✓ Loaded presence: \(presenceData.onlineStatus)")
                }
            } else {
                print("⚠ Could not parse presence (this is optional - app still works)")
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            print("⚠ Presence fetch error: \(error.localizedDescription) (this is optional)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func refreshAllFriends() async {
        // Don't show loading spinner for background refreshes
        let isBackgroundRefresh = !friends.isEmpty && friends.first?.user != nil
        
        if !isBackgroundRefresh {
            await MainActor.run {
                isLoading = true
            }
        }
        
        for friend in friends {
            await fetchFriendData(onlineId: friend.id)
        }
        
        if !isBackgroundRefresh {
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    func fetchFriendData(onlineId: String) async {
        guard let token = accessToken else { return }
        
        // Fetch friend profile using onlineId (username)
        guard let profileUrl = URL(string: "https://us-prof.np.community.playstation.net/userProfile/v1/users/\(onlineId)/profile2?fields=onlineId,accountId,avatarUrls,aboutMe,trophySummary(@default,progress,earnedTrophies)") else { return }
        
        var profileRequest = URLRequest(url: profileUrl)
        profileRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (profileData, response) = try await URLSession.shared.data(for: profileRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Friend Profile Status for \(onlineId): \(httpResponse.statusCode)")
            }
            
            // Debug: Print raw JSON
            if let jsonString = String(data: profileData, encoding: .utf8) {
                print("Friend Profile JSON: \(jsonString)")
            }
            
            if let json = try? JSONDecoder().decode([String: PSNUser].self, from: profileData),
               let profile = json["profile"] {
                print("✓ Loaded friend profile: \(profile.onlineId)")
                
                // Fetch friend presence using accountId
                if let presenceUrl = URL(string: "https://m.np.playstation.com/api/userProfile/v1/internal/users/\(profile.accountId)/basicPresences?type=primary") {
                    var presenceRequest = URLRequest(url: presenceUrl)
                    presenceRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    
                    let (presenceData, _) = try await URLSession.shared.data(for: presenceRequest)
                    
                    var friendPresence: PSNPresence?
                    if let json = try? JSONDecoder().decode([String: PSNPresence].self, from: presenceData),
                       let presenceInfo = json["basicPresence"] {
                        friendPresence = presenceInfo
                        print("✓ Loaded friend presence: \(presenceInfo.onlineStatus)")
                    }
                    
                    await MainActor.run {
                        if let index = friends.firstIndex(where: { $0.id == onlineId }) {
                            // Check for status change
                            let previousStatus = previousFriendStatuses[onlineId]
                            let newStatus = friendPresence?.onlineStatus ?? "unknown"
                            
                            if let prev = previousStatus, prev != newStatus {
                                // Status changed - send notification
                                sendStatusNotification(username: profile.onlineId, newStatus: newStatus, previousStatus: prev)
                            }
                            
                            // Update friend data
                            friends[index].user = profile
                            friends[index].presence = friendPresence
                            previousFriendStatuses[onlineId] = newStatus
                            saveFriends()
                        }
                    }
                }
            } else {
                print("⚠ Failed to parse friend profile JSON")
            }
        } catch {
            print("Error fetching friend data: \(error.localizedDescription)")
        }
    }
    
    func sendStatusNotification(username: String, newStatus: String, previousStatus: String) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        if newStatus.lowercased() == "online" && previousStatus.lowercased() != "online" {
            content.title = "\(username) is now online"
            content.subtitle = "Your friend just came online"
            content.body = "Click to view their profile"
        } else if newStatus.lowercased() == "offline" && previousStatus.lowercased() == "online" {
            content.title = "\(username) went offline"
            content.subtitle = "Your friend is no longer online"
        } else {
            // Other status changes (away, busy, etc.)
            content.title = "\(username) - Status Changed"
            content.body = "Status changed from \(previousStatus) to \(newStatus)"
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchRecentGames() async {
        guard let token = accessToken,
              let accountId = user?.accountId else { return }
        
        guard let url = URL(string: "https://m.np.playstation.com/api/gamelist/v2/users/\(accountId)/titles?limit=10&offset=0") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Recent Games Status: \(httpResponse.statusCode)")
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Recent Games JSON: \(jsonString.prefix(500))")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let titles = json["titles"] as? [[String: Any]] {
                
                var games: [GameTitle] = []
                
                for title in titles.prefix(10) {
                    if let titleId = title["titleId"] as? String,
                       let name = title["name"] as? String {
                        
                        let imageUrl = title["imageUrl"] as? String
                        let platform = title["platform"] as? String
                        let lastPlayed = title["lastPlayedDateTime"] as? String
                        let playDuration = title["playDuration"] as? String
                        
                        // Parse trophy data if available
                        var earnedTrophies: GameTitle.TrophyCount?
                        var definedTrophies: GameTitle.TrophyCount?
                        var progress: Int?
                        var npCommunicationId: String?
                        var npServiceName: String?
                        
                        // Debug: Print the entire title object for one game
                        if name.contains("Battlefield") {
                            if let titleJSON = try? JSONSerialization.data(withJSONObject: title),
                               let titleString = String(data: titleJSON, encoding: .utf8) {
                                print("📊 Full title data for \(name):")
                                print(titleString)
                            }
                        }
                        
                        if let trophyData = title["trophyTitles"] as? [[String: Any]],
                           let firstTrophy = trophyData.first {
                            
                            // Debug: Print trophy data structure
                            if name.contains("Battlefield") {
                                if let trophyJSON = try? JSONSerialization.data(withJSONObject: firstTrophy),
                                   let trophyString = String(data: trophyJSON, encoding: .utf8) {
                                    print("🏆 Trophy data structure:")
                                    print(trophyString)
                                }
                            }
                            
                            // Extract npCommunicationId for detailed trophy fetching
                            npCommunicationId = firstTrophy["npCommunicationId"] as? String
                            npServiceName = firstTrophy["npServiceName"] as? String
                            
                            print("📊 Trophy IDs for \(name):")
                            print("   npCommunicationId: \(npCommunicationId ?? "nil")")
                            print("   npServiceName: \(npServiceName ?? "nil")")
                            
                            if let earned = firstTrophy["earnedTrophies"] as? [String: Int] {
                                earnedTrophies = GameTitle.TrophyCount(
                                    bronze: earned["bronze"] ?? 0,
                                    silver: earned["silver"] ?? 0,
                                    gold: earned["gold"] ?? 0,
                                    platinum: earned["platinum"] ?? 0
                                )
                            }
                            
                            if let defined = firstTrophy["definedTrophies"] as? [String: Int] {
                                definedTrophies = GameTitle.TrophyCount(
                                    bronze: defined["bronze"] ?? 0,
                                    silver: defined["silver"] ?? 0,
                                    gold: defined["gold"] ?? 0,
                                    platinum: defined["platinum"] ?? 0
                                )
                            }
                            
                            progress = firstTrophy["progress"] as? Int
                        }
                        
                        // Try to match game with trophy title map
                        if npCommunicationId == nil, let trophyInfo = trophyTitleMap[name] {
                            npCommunicationId = trophyInfo.npCommunicationId
                            npServiceName = trophyInfo.npServiceName
                            print("✓ Matched \(name) with trophy data from map")
                        }
                        
                        let game = GameTitle(
                            id: titleId,
                            name: name,
                            imageUrl: imageUrl,
                            platform: platform,
                            lastPlayedDateTime: lastPlayed,
                            playDuration: playDuration,
                            progress: progress,
                            earnedTrophies: earnedTrophies,
                            definedTrophies: definedTrophies,
                            npCommunicationId: npCommunicationId,
                            npServiceName: npServiceName
                        )
                        
                        games.append(game)
                    }
                }
                
                await MainActor.run {
                    recentGames = games
                    print("✓ Loaded \(games.count) recent games")
                }
            }
        } catch {
            print("Error fetching recent games: \(error.localizedDescription)")
        }
    }
    
    func fetchUserTrophyTitles() async -> [String: (npCommunicationId: String, npServiceName: String)] {
        guard let token = accessToken,
              let accountId = user?.accountId else {
            print("⚠ Missing token or accountId for trophy titles")
            return [:]
        }
        
        // Fetch user's trophy titles with npCommunicationId
        guard let url = URL(string: "https://m.np.playstation.com/api/trophy/v1/users/\(accountId)/trophyTitles") else {
            return [:]
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Trophy Titles Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    return [:]
                }
            }
            
            // Parse response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let titles = json["trophyTitles"] as? [[String: Any]] {
                
                var trophyMap: [String: (String, String)] = [:]
                
                for title in titles {
                    if let npCommId = title["npCommunicationId"] as? String,
                       let npServiceName = title["npServiceName"] as? String,
                       let titleName = title["trophyTitleName"] as? String {
                        
                        // Use title name as key to match with game titles
                        trophyMap[titleName] = (npCommId, npServiceName)
                        
                        // Also try to match with titleId if available
                        if let trophyTitleDetail = title["trophyTitleDetail"] as? String {
                            trophyMap[trophyTitleDetail] = (npCommId, npServiceName)
                        }
                    }
                }
                
                print("✓ Loaded \(trophyMap.count) trophy title mappings")
                return trophyMap
            }
            
            return [:]
        } catch {
            print("Error fetching trophy titles: \(error.localizedDescription)")
            return [:]
        }
    }
    
    func fetchTrophiesForGame(game: GameTitle) async -> [Trophy]? {
        guard let token = accessToken,
              let accountId = user?.accountId,
              let npCommId = game.npCommunicationId else {
            print("⚠ Missing token, accountId, or npCommunicationId for trophy fetch")
            return nil
        }
        
        // Determine service parameter - default to "trophy" if not specified
        let serviceParam = game.npServiceName ?? "trophy"
        
        // First, fetch trophy definitions (names, descriptions, icons)
        guard let defUrl = URL(string: "https://m.np.playstation.com/api/trophy/v1/npCommunicationIds/\(npCommId)/trophyGroups/all/trophies?npServiceName=\(serviceParam)") else {
            print("⚠ Failed to construct trophy definition URL")
            return nil
        }
        
        var defRequest = URLRequest(url: defUrl)
        defRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        var trophyDefinitions: [Int: [String: Any]] = [:]
        
        do {
            let (defData, defResponse) = try await URLSession.shared.data(for: defRequest)
            
            if let httpResponse = defResponse as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: defData) as? [String: Any],
                   let trophiesArray = json["trophies"] as? [[String: Any]] {
                    for trophy in trophiesArray {
                        if let trophyId = trophy["trophyId"] as? Int {
                            trophyDefinitions[trophyId] = trophy
                        }
                    }
                    print("✓ Loaded \(trophyDefinitions.count) trophy definitions")
                }
            }
        } catch {
            print("⚠ Failed to fetch trophy definitions: \(error.localizedDescription)")
        }
        
        // Now fetch user-specific earned status
        guard let url = URL(string: "https://m.np.playstation.com/api/trophy/v1/users/\(accountId)/npCommunicationIds/\(npCommId)/trophyGroups/all/trophies?npServiceName=\(serviceParam)") else {
            print("⚠ Failed to construct trophy URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Trophy Details Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Trophy Error Response: \(jsonString)")
                    }
                    return nil
                }
            }
            
            // Debug: Print response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Trophy Response: \(jsonString.prefix(500))")
            }
            
            // Parse the response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let trophiesArray = json["trophies"] as? [[String: Any]] {
                
                var trophies: [Trophy] = []
                
                for trophyData in trophiesArray {
                    guard let trophyId = trophyData["trophyId"] as? Int,
                          let trophyType = trophyData["trophyType"] as? String else {
                        continue
                    }
                    
                    // Get definition data if available
                    let definition = trophyDefinitions[trophyId]
                    
                    // Merge data from both sources
                    let trophyName = definition?["trophyName"] as? String ?? trophyData["trophyName"] as? String ?? "Trophy \(trophyId)"
                    let trophyDetail = definition?["trophyDetail"] as? String ?? trophyData["trophyDetail"] as? String ?? ""
                    let trophyIconUrl = definition?["trophyIconUrl"] as? String ?? trophyData["trophyIconUrl"] as? String ?? ""
                    let trophyGroupId = definition?["trophyGroupId"] as? String ?? trophyData["trophyGroupId"] as? String ?? "default"
                    
                    let hidden = trophyData["trophyHidden"] as? Bool ?? false
                    let earned = trophyData["earned"] as? Bool ?? false
                    let earnedDateTime = trophyData["earnedDateTime"] as? String
                    let progressTargetValue = definition?["trophyProgressTargetValue"] as? String ?? trophyData["trophyProgressTargetValue"] as? String
                    let rewardName = definition?["trophyRewardName"] as? String ?? trophyData["trophyRewardName"] as? String
                    let rewardImageUrl = definition?["trophyRewardImageUrl"] as? String ?? trophyData["trophyRewardImageUrl"] as? String
                    
                    let trophy = Trophy(
                        id: trophyId,
                        trophyType: trophyType,
                        trophyName: trophyName,
                        trophyDetail: trophyDetail,
                        trophyIconUrl: trophyIconUrl,
                        trophyGroupId: trophyGroupId,
                        hidden: hidden,
                        earned: earned,
                        earnedDateTime: earnedDateTime,
                        trophyProgressTargetValue: progressTargetValue,
                        trophyRewardName: rewardName,
                        trophyRewardImageUrl: rewardImageUrl
                    )
                    
                    trophies.append(trophy)
                }
                
                print("✓ Loaded \(trophies.count) trophies for \(game.name)")
                return trophies
            }
            
            print("⚠ Failed to parse trophy data")
            return nil
            
        } catch {
            print("Error fetching trophies: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importPSNFriends() async {
        guard let token = accessToken else {
            print("⚠ No access token for importing friends")
            return
        }
        
        guard let url = URL(string: "https://m.np.playstation.com/api/userProfile/v1/internal/users/me/friends?limit=100") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Import Friends Status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode != 200 {
                    print("⚠ Failed to get friends list")
                    return
                }
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let friendAccountIds = json["friends"] as? [String] {
                
                print("✓ Found \(friendAccountIds.count) PSN friend account IDs")
                
                // Fetch profiles for all friends
                await withTaskGroup(of: Void.self) { group in
                    for accountId in friendAccountIds {
                        // Skip if already added
                        if friends.contains(where: { $0.accountId == accountId }) {
                            continue
                        }
                        
                        group.addTask {
                            await self.fetchAndAddFriendByAccountId(accountId: accountId)
                        }
                    }
                }
                
                await MainActor.run {
                    print("✓ Imported \(friendAccountIds.count) PSN friends to UI")
                }
            }
        } catch {
            print("Error importing PSN friends: \(error.localizedDescription)")
        }
    }
    
    func fetchAndAddFriendByAccountId(accountId: String) async {
        guard let token = accessToken else { return }
        
        // Try the mobile API endpoint that accepts accountId
        guard let url = URL(string: "https://m.np.playstation.com/api/userProfile/v1/internal/users/\(accountId)/profiles") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("⚠ Failed to fetch profile for accountId \(accountId): \(httpResponse.statusCode)")
                    
                    // Print response for debugging
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response: \(jsonString)")
                    }
                    return
                }
            }
            
            // Print the full response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Profile response for \(accountId): \(jsonString)")
            }
            
            // Try multiple parsing strategies
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var onlineId: String?
                
                // Strategy 1: profile.onlineId
                if let profile = json["profile"] as? [String: Any],
                   let id = profile["onlineId"] as? String {
                    onlineId = id
                }
                
                // Strategy 2: Direct onlineId
                if onlineId == nil, let id = json["onlineId"] as? String {
                    onlineId = id
                }
                
                // Strategy 3: profiles array
                if onlineId == nil,
                   let profiles = json["profiles"] as? [[String: Any]],
                   let firstProfile = profiles.first,
                   let id = firstProfile["onlineId"] as? String {
                    onlineId = id
                }
                
                if let finalOnlineId = onlineId {
                    print("✓ Fetched profile for \(finalOnlineId)")
                    
                    // Create friend object
                    let friend = Friend(onlineId: finalOnlineId, accountId: accountId, isImported: true)
                    
                    await MainActor.run {
                        // Check again if not already added (race condition)
                        if !friends.contains(where: { $0.accountId == accountId }) {
                            friends.append(friend)
                            saveFriends()
                            print("✓ Added \(finalOnlineId) to friends list")
                        }
                    }
                    
                    // Fetch their full data in background
                    await fetchFriendData(onlineId: finalOnlineId)
                } else {
                    print("⚠ Could not find onlineId in response. Available keys: \(json.keys)")
                }
            }
        } catch {
            print("Error fetching friend profile for \(accountId): \(error.localizedDescription)")
        }
    }
    
    func refresh() async {
        await authenticate()
    }
}
