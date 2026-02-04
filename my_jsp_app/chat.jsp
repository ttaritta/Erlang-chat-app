<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chat</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .header {
            background: white;
            padding: 15px 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header h1 {
            color: #333;
            font-size: 20px;
        }
        .header-right {
            display: flex;
            gap: 15px;
        }
        .back-btn, .logout-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: opacity 0.3s;
        }
        .logout-btn {
            background: #d32f2f;
        }
        .back-btn:hover, .logout-btn:hover {
            opacity: 0.9;
        }
        .chat-container {
            display: flex;
            flex: 1;
            padding: 20px;
            overflow: hidden;
        }
        .messages-box {
            flex: 1;
            background: white;
            border-radius: 10px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .messages-container {
            flex: 1;
            overflow-y: auto;
            margin-bottom: 15px;
            padding-right: 10px;
        }
        .messages-container::-webkit-scrollbar {
            width: 8px;
        }
        .messages-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        .messages-container::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 10px;
        }
        .message {
            margin-bottom: 15px;
            display: flex;
            /* Removed slide-in animation to prevent flicker on refresh */
        }
        .message.own {
            justify-content: flex-end;
            width: 100%;
        }
        .message.other {
            width: 100%;
            justify-content: flex-start;
        }
        .message.own > div {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            width: fit-content;
            max-width: 85%;
        }
        .message.other > div {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            width: fit-content;
            max-width: 85%;
        }
        .message-content {
            padding: 10px 15px;
            border-radius: 15px;
            white-space: normal;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        .message.own .message-content {
            background: #667eea;
            color: white;
            border-bottom-right-radius: 5px;
            max-width: 100%;
            word-break: break-word;
            overflow-wrap: break-word;
        }
        .message.other .message-content {
            background: #f0f0f0;
            color: #333;
            border-bottom-left-radius: 5px;
            word-break: break-word;
            overflow-wrap: break-word;
        }
        .message-sender {
            font-size: 12px;
            color: #999;
            margin-bottom: 3px;
        }
        .message.own .message-sender {
            text-align: right;
        }
        .message.other .message-sender {
            text-align: left;
        }
        .message.own .message-sender {
            text-align: right;
        }
        .input-box {
            display: flex;
            gap: 10px;
        }
        #messageInput {
            flex: 1;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 25px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        #messageInput:focus {
            outline: none;
            border-color: #667eea;
        }
        .send-btn {
            background: #667eea;
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: bold;
            transition: opacity 0.3s;
        }
        .send-btn:hover:not(:disabled) {
            opacity: 0.9;
        }
        .send-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .empty-state {
            text-align: center;
            color: #999;
            padding: 40px;
        }
        .error {
            background: #ffebee;
            color: #d32f2f;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 10px;
            display: none;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Chat sa <span id="chatWithUser"></span></h1>
        <div class="header-right">
            <button class="back-btn" onclick="goBack()">Nazad</button>
            <button class="logout-btn" onclick="handleLogout()">Odjava</button>
        </div>
    </div>

    <div class="chat-container">
        <div class="messages-box">
            <div class="error" id="error"></div>
            <div class="messages-container" id="messagesContainer">
                <div class="empty-state">Učitavanje poruka...</div>
            </div>
            <div class="input-box">
                <input type="text" id="messageInput" placeholder="Unesite poruku...">
                <button class="send-btn" id="sendBtn" onclick="sendMessage()">Pošalji</button>
            </div>
        </div>
    </div>

    <script>
        let currentUsername;
        let chatWithUsername;
        let lastRenderedKey = '';
        
        document.addEventListener('DOMContentLoaded', function() {
            currentUsername = sessionStorage.getItem('username');
            chatWithUsername = sessionStorage.getItem('chatWith');
            
            if (!currentUsername || !chatWithUsername) {
                window.location.href = 'login.jsp';
                return;
            }
            
            document.getElementById('chatWithUser').textContent = chatWithUsername;
            loadMessages();
            // Osvežavaj poruke svakih 500ms
            setInterval(loadMessages, 500);
        });
        
        function loadMessages() {
            // Jedan poziv koji vraća spojen razgovor A<->B sa backend-a
            const url = 'http://10.2.1.32:8082/conversation?a=' + encodeURIComponent(currentUsername) + '&b=' + encodeURIComponent(chatWithUsername);
            fetch(url)
                .then(resp => {
                    console.log('Fetch', url, 'status:', resp.status);
                    if (!resp.ok) throw new Error('Greška pri učitavanju: ' + url);
                    return resp.json();
                })
                .then(messages => {
                    console.log('Conversation messages:', messages);
                    displayMessages(Array.isArray(messages) ? messages : []);
                })
                .catch(err => {
                    console.error('Load conversation error:', err);
                });
        }
        
        function displayMessages(messages) {
            const container = document.getElementById('messagesContainer');
            const key = JSON.stringify(messages || []);
            // Avoid re-rendering when nothing changed to prevent flicker
            if (key === lastRenderedKey) {
                return;
            }
            
            if (!messages || messages.length === 0) {
                container.innerHTML = '<div class="empty-state">Nema poruka. Započnite razgovor!</div>';
                lastRenderedKey = key;
                return;
            }
            
            container.innerHTML = '';
            messages.forEach(msg => {
                const isOwn = msg[0].toLowerCase() === currentUsername.toLowerCase();
                const messageDiv = document.createElement('div');
                messageDiv.className = 'message ' + (isOwn ? 'own' : 'other');
                messageDiv.innerHTML = '<div><div class="message-sender">' + escapeHtml(msg[0]) + '</div><div class="message-content">' + escapeHtml(msg[1]) + '</div></div>';
                container.appendChild(messageDiv);
            });
            
            // Skroluj na dno samo kad ima promena
            container.scrollTop = container.scrollHeight;
            lastRenderedKey = key;
        }
        
        function sendMessage() {
            const input = document.getElementById('messageInput');
            const message = input.value.trim();
            
            if (!message) return;
            
            const sendBtn = document.getElementById('sendBtn');
            sendBtn.disabled = true;
            
            fetch('http://10.2.1.32:8082/msg', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    from: currentUsername,
                    to: chatWithUsername,
                    text: message
                })
            })
            .then(resp => {
                if (!resp.ok) throw new Error('Greška pri slanju');
                input.value = '';
                loadMessages();
            })
            .catch(err => {
                console.error('Send message error:', err);
                showError('Greška pri slanju poruke');
            })
            .finally(() => {
                sendBtn.disabled = false;
                input.focus();
            });
        }
        
        function goBack() {
            window.location.href = 'users.jsp';
        }
        
        function handleLogout() {
            sessionStorage.clear();
            window.location.href = 'login.jsp';
        }
        
        function showError(msg) {
            const errorDiv = document.getElementById('error');
            errorDiv.textContent = msg;
            errorDiv.style.display = 'block';
            setTimeout(() => {
                errorDiv.style.display = 'none';
            }, 3000);
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
        
        // Enter key support
        document.getElementById('messageInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
    </script>
</body>
</html>
