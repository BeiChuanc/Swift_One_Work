import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Bague {
    /// 个人聊天
    case personal_bague
    /// 群聊
    case group_bague
    /// AI聊天
    case ai_bague
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Bague {
    
    /// 单例
    static let shared_Bague = MessageViewModel_Bague()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Bague = Notification.Name("MessageStateDidChange_Bague")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Bague: [Int: [MessageModel_Bague]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Bague: [Int: GroupChatInfo_Bague] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Bague: [MessageModel_Bague] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Bague: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Bague() {
        userMesMap_Bague = [:]
        aiChats_Bague = []
        notifyStateChange_Bague()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Bague() -> [Int: GroupChatInfo_Bague] {
        return groupChats_Bague
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Bague(userId_bague: Int) -> [MessageModel_Bague] {
        return userMesMap_Bague[userId_bague] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Bague() -> [PrewUserModel_Bague] {
        let userIds_bague = userMesMap_Bague.keys
        return LocalData_Bague.shared_Bague.userList_Bague.filter { user in
            guard let userId = user.userId_Bague else { return false }
            return userIds_bague.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Bague() -> [MessageModel_Bague] {
        return aiChats_Bague
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Bague(groupId_bague: Int) -> [MessageModel_Bague] {
        return groupChats_Bague[groupId_bague]?.messages_bague ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Bague(userId_bague: Int) -> MessageModel_Bague? {
        return userMesMap_Bague[userId_bague]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Bague(message_bague: String, chatType_bague: ChatType_Bague, id_bague: Int) {
        let currentTime_bague = getCurrentTime_Bague()
        
        let chatMessage_bague = MessageModel_Bague(
            messageId_bague: Int(Date().timeIntervalSince1970 * 1000),
            content_bague: message_bague,
            userHead_bague: "current_user_head", // 这里应该从UserViewModel获取
            isMine_bague: true,
            time_bague: currentTime_bague
        )
        
        switch chatType_bague {
        case .personal_bague:
            // 个人聊天
            if userMesMap_Bague[id_bague] == nil {
                userMesMap_Bague[id_bague] = []
            }
            userMesMap_Bague[id_bague]?.append(chatMessage_bague)
            handleMessage_Bague(message_bague: chatMessage_bague, id_bague: id_bague, chatType_bague: chatType_bague)
            
        case .group_bague:
            // 群聊
            if var groupInfo_bague = groupChats_Bague[id_bague] {
                groupInfo_bague.messages_bague.append(chatMessage_bague)
                groupChats_Bague[id_bague] = groupInfo_bague
            } else {
                groupChats_Bague[id_bague] = GroupChatInfo_Bague(
                    gid_bague: id_bague,
                    intro_bague: "",
                    cover_bague: "",
                    join_bague: "",
                    messages_bague: [chatMessage_bague]
                )
            }
            
        case .ai_bague:
            // AI聊天
            aiChats_Bague.append(chatMessage_bague)
            handleMessage_Bague(message_bague: chatMessage_bague, id_bague: id_bague, chatType_bague: chatType_bague)
        }
        
        notifyStateChange_Bague()
    }
    
    /// 处理消息回复
    private func handleMessage_Bague(message_bague: MessageModel_Bague, id_bague: Int, chatType_bague: ChatType_Bague) {
        Task {
            let response_bague = await chatService_Bague(
                userId_bague: 0, // 这里应该从UserViewModel获取
                message_bague: message_bague.content_Bague ?? ""
            )
            
            let replyMessage_bague = MessageModel_Bague(
                messageId_bague: Int(Date().timeIntervalSince1970 * 1000),
                content_bague: response_bague ?? "Server error",
                userHead_bague: "",
                isMine_bague: false,
                time_bague: getCurrentTime_Bague()
            )
            
            switch chatType_bague {
            case .ai_bague:
                aiChats_Bague.append(replyMessage_bague)
                
            case .personal_bague:
                if userMesMap_Bague[id_bague] == nil {
                    userMesMap_Bague[id_bague] = []
                }
                userMesMap_Bague[id_bague]?.append(replyMessage_bague)
                
            case .group_bague:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Bague()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Bague(groupId_bague: Int) {
        if var groupInfo_bague = groupChats_Bague[groupId_bague] {
            groupInfo_bague.messages_bague = []
            groupChats_Bague[groupId_bague] = groupInfo_bague
            notifyStateChange_Bague()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Bague(groupId_bague: Int) {
        groupChats_Bague.removeValue(forKey: groupId_bague)
        notifyStateChange_Bague()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Bague() {
        aiChats_Bague = []
        notifyStateChange_Bague()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Bague(userId_bague: Int) {
        userMesMap_Bague.removeValue(forKey: userId_bague)
        notifyStateChange_Bague()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Bague() {
        userMesMap_Bague = [:]
        groupChats_Bague = [:]
        aiChats_Bague = []
        notifyStateChange_Bague()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Bague() -> String {
        let formatter_bague = DateFormatter()
        formatter_bague.dateFormat = "HH:mm"
        return formatter_bague.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Bague() {
        NotificationCenter.default.post(
            name: MessageViewModel_Bague.messageStateDidChangeNotification_Bague,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Bague(userId_bague: Int, message_bague: String) async -> String? {
        do {
            let bundleId_bague = "com.bague.app"
            let timestamp_bague = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_bague = generateRandomString_Bague(length_bague: 16)
            let sessionId_bague = "\(timestamp_bague)_\(randomString_bague)"
            
            // 解密URL
            let urlString_bague = decryptUrl_Bague(encryptedCodes_bague: MessageViewModel_Bague.chatService_Bague)
            guard let url_bague = URL(string: urlString_bague) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_bague = URLRequest(url: url_bague)
            request_bague.httpMethod = "POST"
            request_bague.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_bague: [String: Any] = [
                "bundle_id": bundleId_bague,
                "session_id": sessionId_bague,
                "content_type": "text",
                "content": message_bague
            ]
            
            request_bague.httpBody = try JSONSerialization.data(withJSONObject: body_bague)
            
            let (data_bague, response_bague) = try await URLSession.shared.data(for: request_bague)
            
            if let httpResponse_bague = response_bague as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_bague.statusCode)")
                
                if httpResponse_bague.statusCode == 200 {
                    if let json_bague = try JSONSerialization.jsonObject(with: data_bague) as? [String: Any],
                       let code_bague = json_bague["code"] as? Int,
                       code_bague == 1003,
                       let data_bague = json_bague["data"] as? [String: Any],
                       let answer_bague = data_bague["answer"] as? String,
                       !answer_bague.isEmpty {
                        return answer_bague
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
    static func encryptUrl_Bague(plainUrl_Bague: String) -> [Int] {
        let xorKey_Bague = 20 // 异或密钥
        let offset_Bague = 23 // 字符偏移量
        
        var result_Bague: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Bague in plainUrl_Bague.unicodeScalars {
            let charCode_Bague = Int(char_Bague.value) + offset_Bague
            result_Bague.append(charCode_Bague)
        }
        
        // 第二层：异或加密
        var finalResult_Bague: [Int] = []
        for code_Bague in result_Bague {
            finalResult_Bague.append(code_Bague ^ xorKey_Bague)
        }
        
        print("✅ URL加密结果: \(finalResult_Bague)")
        return finalResult_Bague
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Bague(encryptedCodes_bague: [Int]) -> String {
        let xorKey_bague = 20 // 异或密钥
        let offset_bague = 23 // 字符偏移量
        
        var result_bague = ""
        
        // 第一层：异或解密
        for code_bague in encryptedCodes_bague {
            let charCode_bague = code_bague ^ xorKey_bague
            if let scalar_bague = UnicodeScalar(charCode_bague) {
                result_bague.append(Character(scalar_bague))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_bague = ""
        for char_bague in result_bague.unicodeScalars {
            let charCode_bague = Int(char_bague.value) - offset_bague
            if let scalar_bague = UnicodeScalar(charCode_bague) {
                finalResult_bague.append(Character(scalar_bague))
            }
        }
        
        return finalResult_bague
    }
    
    /// 生成随机字符串
    private func generateRandomString_Bague(length_bague: Int) -> String {
        let letters_bague = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_bague).map { _ in letters_bague.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Bague {
    /// 群组ID
    var gid_bague: Int
    /// 群组简介
    var intro_bague: String
    /// 群组封面
    var cover_bague: String
    /// 加入信息
    var join_bague: String
    /// 消息列表
    var messages_bague: [MessageModel_Bague]
}
