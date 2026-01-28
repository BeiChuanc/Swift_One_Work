import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Wanderbell {
    /// 个人聊天
    case personal_wanderbell
    /// 群聊
    case group_wanderbell
    /// AI聊天
    case ai_wanderbell
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Wanderbell {
    
    /// 单例
    static let shared_Wanderbell = MessageViewModel_Wanderbell()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Wanderbell = Notification.Name("MessageStateDidChange_Wanderbell")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Wanderbell: [Int: [MessageModel_Wanderbell]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Wanderbell: [Int: GroupChatInfo_Wanderbell] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Wanderbell: [MessageModel_Wanderbell] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Wanderbell: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Wanderbell() {
        userMesMap_Wanderbell = [:]
        aiChats_Wanderbell = []
        setGroup_Wanderbell()
        notifyStateChange_Wanderbell()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Wanderbell() {
        groupChats_Wanderbell = [
            10: GroupChatInfo_Wanderbell(
                gid_wanderbell: 10,
                intro_wanderbell: "Bonfire Stories Hub",
                cover_wanderbell: "",
                join_wanderbell: "",
                messages_wanderbell: []
            ),
            11: GroupChatInfo_Wanderbell(
                gid_wanderbell: 11,
                intro_wanderbell: "Night Gathering Friends",
                cover_wanderbell: "",
                join_wanderbell: "",
                messages_wanderbell: []
            ),
            12: GroupChatInfo_Wanderbell(
                gid_wanderbell: 12,
                intro_wanderbell: "Campfire Adventure Team",
                cover_wanderbell: "",
                join_wanderbell: "",
                messages_wanderbell: []
            ),
            13: GroupChatInfo_Wanderbell(
                gid_wanderbell: 13,
                intro_wanderbell: "Outdoor Bonfire Lovers",
                cover_wanderbell: "",
                join_wanderbell: "",
                messages_wanderbell: []
            ),
            14: GroupChatInfo_Wanderbell(
                gid_wanderbell: 14,
                intro_wanderbell: "Warm Fire Community",
                cover_wanderbell: "",
                join_wanderbell: "",
                messages_wanderbell: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Wanderbell() -> [Int: GroupChatInfo_Wanderbell] {
        return groupChats_Wanderbell
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Wanderbell(userId_wanderbell: Int) -> [MessageModel_Wanderbell] {
        return userMesMap_Wanderbell[userId_wanderbell] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Wanderbell() -> [PrewUserModel_Wanderbell] {
        let userIds_wanderbell = userMesMap_Wanderbell.keys
        return LocalData_Wanderbell.shared_Wanderbell.userList_Wanderbell.filter { user in
            guard let userId = user.userId_Wanderbell else { return false }
            return userIds_wanderbell.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Wanderbell() -> [MessageModel_Wanderbell] {
        return aiChats_Wanderbell
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Wanderbell(groupId_wanderbell: Int) -> [MessageModel_Wanderbell] {
        return groupChats_Wanderbell[groupId_wanderbell]?.messages_wanderbell ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Wanderbell(userId_wanderbell: Int) -> MessageModel_Wanderbell? {
        return userMesMap_Wanderbell[userId_wanderbell]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Wanderbell(message_wanderbell: String, chatType_wanderbell: ChatType_Wanderbell, id_wanderbell: Int) {
        let currentTime_wanderbell = getCurrentTime_Wanderbell()
        
        let chatMessage_wanderbell = MessageModel_Wanderbell(
            messageId_wanderbell: Int(Date().timeIntervalSince1970 * 1000),
            content_wanderbell: message_wanderbell,
            userHead_wanderbell: "current_user_head", // 这里应该从UserViewModel获取
            isMine_wanderbell: true,
            time_wanderbell: currentTime_wanderbell
        )
        
        switch chatType_wanderbell {
        case .personal_wanderbell:
            // 个人聊天
            if userMesMap_Wanderbell[id_wanderbell] == nil {
                userMesMap_Wanderbell[id_wanderbell] = []
            }
            userMesMap_Wanderbell[id_wanderbell]?.append(chatMessage_wanderbell)
            handleMessage_Wanderbell(message_wanderbell: chatMessage_wanderbell, id_wanderbell: id_wanderbell, chatType_wanderbell: chatType_wanderbell)
            
        case .group_wanderbell:
            // 群聊
            if var groupInfo_wanderbell = groupChats_Wanderbell[id_wanderbell] {
                groupInfo_wanderbell.messages_wanderbell.append(chatMessage_wanderbell)
                groupChats_Wanderbell[id_wanderbell] = groupInfo_wanderbell
            } else {
                groupChats_Wanderbell[id_wanderbell] = GroupChatInfo_Wanderbell(
                    gid_wanderbell: id_wanderbell,
                    intro_wanderbell: "",
                    cover_wanderbell: "",
                    join_wanderbell: "",
                    messages_wanderbell: [chatMessage_wanderbell]
                )
            }
            
        case .ai_wanderbell:
            // AI聊天
            aiChats_Wanderbell.append(chatMessage_wanderbell)
            handleMessage_Wanderbell(message_wanderbell: chatMessage_wanderbell, id_wanderbell: id_wanderbell, chatType_wanderbell: chatType_wanderbell)
        }
        
        notifyStateChange_Wanderbell()
    }
    
    /// 处理消息回复
    private func handleMessage_Wanderbell(message_wanderbell: MessageModel_Wanderbell, id_wanderbell: Int, chatType_wanderbell: ChatType_Wanderbell) {
        Task {
            let response_wanderbell = await chatService_Wanderbell(
                userId_wanderbell: 0, // 这里应该从UserViewModel获取
                message_wanderbell: message_wanderbell.content_Wanderbell ?? ""
            )
            
            let replyMessage_wanderbell = MessageModel_Wanderbell(
                messageId_wanderbell: Int(Date().timeIntervalSince1970 * 1000),
                content_wanderbell: response_wanderbell ?? "Server error",
                userHead_wanderbell: "",
                isMine_wanderbell: false,
                time_wanderbell: getCurrentTime_Wanderbell()
            )
            
            switch chatType_wanderbell {
            case .ai_wanderbell:
                aiChats_Wanderbell.append(replyMessage_wanderbell)
                
            case .personal_wanderbell:
                if userMesMap_Wanderbell[id_wanderbell] == nil {
                    userMesMap_Wanderbell[id_wanderbell] = []
                }
                userMesMap_Wanderbell[id_wanderbell]?.append(replyMessage_wanderbell)
                
            case .group_wanderbell:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Wanderbell()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Wanderbell(groupId_wanderbell: Int) {
        if var groupInfo_wanderbell = groupChats_Wanderbell[groupId_wanderbell] {
            groupInfo_wanderbell.messages_wanderbell = []
            groupChats_Wanderbell[groupId_wanderbell] = groupInfo_wanderbell
            notifyStateChange_Wanderbell()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Wanderbell(groupId_wanderbell: Int) {
        groupChats_Wanderbell.removeValue(forKey: groupId_wanderbell)
        notifyStateChange_Wanderbell()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Wanderbell() {
        aiChats_Wanderbell = []
        notifyStateChange_Wanderbell()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Wanderbell(userId_wanderbell: Int) {
        userMesMap_Wanderbell.removeValue(forKey: userId_wanderbell)
        notifyStateChange_Wanderbell()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Wanderbell() {
        userMesMap_Wanderbell = [:]
        groupChats_Wanderbell = [:]
        aiChats_Wanderbell = []
        notifyStateChange_Wanderbell()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Wanderbell() -> String {
        let formatter_wanderbell = DateFormatter()
        formatter_wanderbell.dateFormat = "HH:mm"
        return formatter_wanderbell.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Wanderbell() {
        NotificationCenter.default.post(
            name: MessageViewModel_Wanderbell.messageStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Wanderbell(userId_wanderbell: Int, message_wanderbell: String) async -> String? {
        do {
            let bundleId_wanderbell = "com.wanderbell.app"
            let timestamp_wanderbell = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_wanderbell = generateRandomString_Wanderbell(length_wanderbell: 16)
            let sessionId_wanderbell = "\(timestamp_wanderbell)_\(randomString_wanderbell)"
            
            // 解密URL
            let urlString_wanderbell = decryptUrl_Wanderbell(encryptedCodes_wanderbell: MessageViewModel_Wanderbell.chatService_Wanderbell)
            guard let url_wanderbell = URL(string: urlString_wanderbell) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_wanderbell = URLRequest(url: url_wanderbell)
            request_wanderbell.httpMethod = "POST"
            request_wanderbell.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_wanderbell: [String: Any] = [
                "bundle_id": bundleId_wanderbell,
                "session_id": sessionId_wanderbell,
                "content_type": "text",
                "content": message_wanderbell
            ]
            
            request_wanderbell.httpBody = try JSONSerialization.data(withJSONObject: body_wanderbell)
            
            let (data_wanderbell, response_wanderbell) = try await URLSession.shared.data(for: request_wanderbell)
            
            if let httpResponse_wanderbell = response_wanderbell as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_wanderbell.statusCode)")
                
                if httpResponse_wanderbell.statusCode == 200 {
                    if let json_wanderbell = try JSONSerialization.jsonObject(with: data_wanderbell) as? [String: Any],
                       let code_wanderbell = json_wanderbell["code"] as? Int,
                       code_wanderbell == 1003,
                       let data_wanderbell = json_wanderbell["data"] as? [String: Any],
                       let answer_wanderbell = data_wanderbell["answer"] as? String,
                       !answer_wanderbell.isEmpty {
                        return answer_wanderbell
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Wanderbell(encryptedCodes_wanderbell: [Int]) -> String {
        let xorKey_wanderbell = 20 // 异或密钥
        let offset_wanderbell = 23 // 字符偏移量
        
        var result_wanderbell = ""
        
        // 第一层：异或解密
        for code_wanderbell in encryptedCodes_wanderbell {
            let charCode_wanderbell = code_wanderbell ^ xorKey_wanderbell
            if let scalar_wanderbell = UnicodeScalar(charCode_wanderbell) {
                result_wanderbell.append(Character(scalar_wanderbell))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_wanderbell = ""
        for char_wanderbell in result_wanderbell.unicodeScalars {
            let charCode_wanderbell = Int(char_wanderbell.value) - offset_wanderbell
            if let scalar_wanderbell = UnicodeScalar(charCode_wanderbell) {
                finalResult_wanderbell.append(Character(scalar_wanderbell))
            }
        }
        
        return finalResult_wanderbell
    }
    
    /// 生成随机字符串
    private func generateRandomString_Wanderbell(length_wanderbell: Int) -> String {
        let letters_wanderbell = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_wanderbell).map { _ in letters_wanderbell.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Wanderbell {
    /// 群组ID
    var gid_wanderbell: Int
    /// 群组简介
    var intro_wanderbell: String
    /// 群组封面
    var cover_wanderbell: String
    /// 加入信息
    var join_wanderbell: String
    /// 消息列表
    var messages_wanderbell: [MessageModel_Wanderbell]
}
