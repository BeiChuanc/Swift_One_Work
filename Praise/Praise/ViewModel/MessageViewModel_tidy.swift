import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Tidy {
    /// 个人聊天
    case personal_tidy
    /// 群聊
    case group_tidy
    /// AI聊天
    case ai_tidy
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Tidy {
    
    /// 单例
    static let shared_Tidy = MessageViewModel_Tidy()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Tidy = Notification.Name("MessageStateDidChange_Tidy")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Tidy: [Int: [MessageModel_Tidy]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Tidy: [Int: GroupChatInfo_Tidy] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Tidy: [MessageModel_Tidy] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Tidy: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Tidy() {
        userMesMap_Tidy = [:]
        aiChats_Tidy = []
        notifyStateChange_Tidy()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Tidy() -> [Int: GroupChatInfo_Tidy] {
        return groupChats_Tidy
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Tidy(userId_tidy: Int) -> [MessageModel_Tidy] {
        return userMesMap_Tidy[userId_tidy] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Tidy() -> [PrewUserModel_Tidy] {
        let userIds_tidy = userMesMap_Tidy.keys
        return LocalData_Tidy.shared_Tidy.userList_Tidy.filter { user in
            guard let userId = user.userId_Tidy else { return false }
            return userIds_tidy.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Tidy() -> [MessageModel_Tidy] {
        return aiChats_Tidy
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Tidy(groupId_tidy: Int) -> [MessageModel_Tidy] {
        return groupChats_Tidy[groupId_tidy]?.messages_tidy ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Tidy(userId_tidy: Int) -> MessageModel_Tidy? {
        return userMesMap_Tidy[userId_tidy]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Tidy(message_tidy: String, chatType_tidy: ChatType_Tidy, id_tidy: Int) {
        let currentTime_tidy = getCurrentTime_Tidy()
        
        let chatMessage_tidy = MessageModel_Tidy(
            messageId_tidy: Int(Date().timeIntervalSince1970 * 1000),
            content_tidy: message_tidy,
            userHead_tidy: "current_user_head", // 这里应该从UserViewModel获取
            isMine_tidy: true,
            time_tidy: currentTime_tidy
        )
        
        switch chatType_tidy {
        case .personal_tidy:
            // 个人聊天
            if userMesMap_Tidy[id_tidy] == nil {
                userMesMap_Tidy[id_tidy] = []
            }
            userMesMap_Tidy[id_tidy]?.append(chatMessage_tidy)
            handleMessage_Tidy(message_tidy: chatMessage_tidy, id_tidy: id_tidy, chatType_tidy: chatType_tidy)
            
        case .group_tidy:
            // 群聊
            if var groupInfo_tidy = groupChats_Tidy[id_tidy] {
                groupInfo_tidy.messages_tidy.append(chatMessage_tidy)
                groupChats_Tidy[id_tidy] = groupInfo_tidy
            } else {
                groupChats_Tidy[id_tidy] = GroupChatInfo_Tidy(
                    gid_tidy: id_tidy,
                    intro_tidy: "",
                    cover_tidy: "",
                    join_tidy: "",
                    messages_tidy: [chatMessage_tidy]
                )
            }
            
        case .ai_tidy:
            // AI聊天
            aiChats_Tidy.append(chatMessage_tidy)
            handleMessage_Tidy(message_tidy: chatMessage_tidy, id_tidy: id_tidy, chatType_tidy: chatType_tidy)
        }
        
        notifyStateChange_Tidy()
    }
    
    /// 处理消息回复
    private func handleMessage_Tidy(message_tidy: MessageModel_Tidy, id_tidy: Int, chatType_tidy: ChatType_Tidy) {
        Task {
            let response_tidy = await chatService_Tidy(
                userId_tidy: 0, // 这里应该从UserViewModel获取
                message_tidy: message_tidy.content_Tidy ?? ""
            )
            
            let replyMessage_tidy = MessageModel_Tidy(
                messageId_tidy: Int(Date().timeIntervalSince1970 * 1000),
                content_tidy: response_tidy ?? "Server error",
                userHead_tidy: "",
                isMine_tidy: false,
                time_tidy: getCurrentTime_Tidy()
            )
            
            switch chatType_tidy {
            case .ai_tidy:
                aiChats_Tidy.append(replyMessage_tidy)
                
            case .personal_tidy:
                if userMesMap_Tidy[id_tidy] == nil {
                    userMesMap_Tidy[id_tidy] = []
                }
                userMesMap_Tidy[id_tidy]?.append(replyMessage_tidy)
                
            case .group_tidy:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Tidy()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Tidy(groupId_tidy: Int) {
        if var groupInfo_tidy = groupChats_Tidy[groupId_tidy] {
            groupInfo_tidy.messages_tidy = []
            groupChats_Tidy[groupId_tidy] = groupInfo_tidy
            notifyStateChange_Tidy()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Tidy(groupId_tidy: Int) {
        groupChats_Tidy.removeValue(forKey: groupId_tidy)
        notifyStateChange_Tidy()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Tidy() {
        aiChats_Tidy = []
        notifyStateChange_Tidy()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Tidy(userId_tidy: Int) {
        userMesMap_Tidy.removeValue(forKey: userId_tidy)
        notifyStateChange_Tidy()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Tidy() {
        userMesMap_Tidy = [:]
        groupChats_Tidy = [:]
        aiChats_Tidy = []
        notifyStateChange_Tidy()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Tidy() -> String {
        let formatter_tidy = DateFormatter()
        formatter_tidy.dateFormat = "HH:mm"
        return formatter_tidy.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Tidy() {
        NotificationCenter.default.post(
            name: MessageViewModel_Tidy.messageStateDidChangeNotification_Tidy,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Tidy(userId_tidy: Int, message_tidy: String) async -> String? {
        do {
            let bundleId_tidy = "com.tidy.app"
            let timestamp_tidy = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_tidy = generateRandomString_Tidy(length_tidy: 16)
            let sessionId_tidy = "\(timestamp_tidy)_\(randomString_tidy)"
            
            // 解密URL
            let urlString_tidy = decryptUrl_Tidy(encryptedCodes_tidy: MessageViewModel_Tidy.chatService_Tidy)
            guard let url_tidy = URL(string: urlString_tidy) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_tidy = URLRequest(url: url_tidy)
            request_tidy.httpMethod = "POST"
            request_tidy.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_tidy: [String: Any] = [
                "bundle_id": bundleId_tidy,
                "session_id": sessionId_tidy,
                "content_type": "text",
                "content": message_tidy
            ]
            
            request_tidy.httpBody = try JSONSerialization.data(withJSONObject: body_tidy)
            
            let (data_tidy, response_tidy) = try await URLSession.shared.data(for: request_tidy)
            
            if let httpResponse_tidy = response_tidy as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_tidy.statusCode)")
                
                if httpResponse_tidy.statusCode == 200 {
                    if let json_tidy = try JSONSerialization.jsonObject(with: data_tidy) as? [String: Any],
                       let code_tidy = json_tidy["code"] as? Int,
                       code_tidy == 1003,
                       let data_tidy = json_tidy["data"] as? [String: Any],
                       let answer_tidy = data_tidy["answer"] as? String,
                       !answer_tidy.isEmpty {
                        return answer_tidy
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Tidy(plainUrl_Tidy: String) -> [Int] {
        let xorKey_Tidy = 20 // 异或密钥
        let offset_Tidy = 23 // 字符偏移量
        
        var result_Tidy: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Tidy in plainUrl_Tidy.unicodeScalars {
            let charCode_Tidy = Int(char_Tidy.value) + offset_Tidy
            result_Tidy.append(charCode_Tidy)
        }
        
        // 第二层：异或加密
        var finalResult_Tidy: [Int] = []
        for code_Tidy in result_Tidy {
            finalResult_Tidy.append(code_Tidy ^ xorKey_Tidy)
        }
        
        print("✅ URL加密结果: \(finalResult_Tidy)")
        return finalResult_Tidy
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Tidy(encryptedCodes_tidy: [Int]) -> String {
        let xorKey_tidy = 20 // 异或密钥
        let offset_tidy = 23 // 字符偏移量
        
        var result_tidy = ""
        
        // 第一层：异或解密
        for code_tidy in encryptedCodes_tidy {
            let charCode_tidy = code_tidy ^ xorKey_tidy
            if let scalar_tidy = UnicodeScalar(charCode_tidy) {
                result_tidy.append(Character(scalar_tidy))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_tidy = ""
        for char_tidy in result_tidy.unicodeScalars {
            let charCode_tidy = Int(char_tidy.value) - offset_tidy
            if let scalar_tidy = UnicodeScalar(charCode_tidy) {
                finalResult_tidy.append(Character(scalar_tidy))
            }
        }
        
        return finalResult_tidy
    }
    
    /// 生成随机字符串
    private func generateRandomString_Tidy(length_tidy: Int) -> String {
        let letters_tidy = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_tidy).map { _ in letters_tidy.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Tidy {
    /// 群组ID
    var gid_tidy: Int
    /// 群组简介
    var intro_tidy: String
    /// 群组封面
    var cover_tidy: String
    /// 加入信息
    var join_tidy: String
    /// 消息列表
    var messages_tidy: [MessageModel_Tidy]
}
