    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Aktivni Korisnici</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .header {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        .header h1 {
            color: #333;
            font-size: 24px;
        }
        .user-info {
            color: #666;
            font-size: 14px;
        }
        .logout-btn {
            background: #d32f2f;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: opacity 0.3s;
        }
        .logout-btn:hover {
            opacity: 0.9;
        }
        .users-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
        }
        .user-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #667eea;
        }
        .user-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
            border-left-color: #764ba2;
        }
        .user-card h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 18px;
        }
        .status {
            color: #4caf50;
            font-size: 12px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .status::before {
            content: '';
            width: 8px;
            height: 8px;
            background: #4caf50;
            border-radius: 50%;
            display: inline-block;
        }
        .empty-state {
            background: white;
            padding: 40px;
            border-radius: 10px;
            text-align: center;
            color: #999;
        }
        .loading {
            text-align: center;
            padding: 40px;
            color: white;
            font-size: 18px;
        }
        .error {
            background: #ffebee;
            color: #d32f2f;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div>
                <h1>Aktivni Korisnici</h1>
                <div class="user-info">Prijavljeni kao: <strong id="currentUser"></strong></div>
            </div>
            <button class="logout-btn" onclick="handleLogout()">Odjava</button>
        </div>
        
        <div id="error" class="error" style="display: none;"></div>
        <div id="loading" class="loading">Učitavanje korisnika...</div>
        <div id="usersContainer" class="users-grid" style="display: none;"></div>
    </div>

    <script>
        let currentUsername;
        
        document.addEventListener('DOMContentLoaded', function() {
            currentUsername = sessionStorage.getItem('username');
            
            if (!currentUsername) {
                window.location.href = 'login.jsp';
                return;
            }
            
            document.getElementById('currentUser').textContent = currentUsername;
            loadUsers();
            // Osvežavaj listu korisnika svakih 3 sekunde
            setInterval(loadUsers, 3000);
        });
        
        function loadUsers() {
            fetch('http://10.2.1.32:8082/users')
                .then(resp => {
                    if (!resp.ok) throw new Error('Greška pri učitavanju');
                    return resp.json();
                })
                .then(users => {
                    displayUsers(users);
                })
                .catch(err => {
                    console.error('Load users error:', err);
                    showError('Greška pri učitavanju korisnika');
                });
        }
        
        function displayUsers(users) {
            const container = document.getElementById('usersContainer');
            const loading = document.getElementById('loading');
            
            if (!users || users.length === 0) {
                loading.textContent = 'Nema aktivnih korisnika';
                loading.style.display = 'block';
                container.style.display = 'none';
                return;
            }
            
            // Filtriraj trenutnog korisnika
            const otherUsers = users.filter(u => u.toLowerCase() !== currentUsername.toLowerCase());
            
            container.innerHTML = '';
            otherUsers.forEach(user => {
                const card = document.createElement('div');
                card.className = 'user-card';
                card.innerHTML = '<h3>' + escapeHtml(user) + '</h3><div class="status">Online</div>';
                card.onclick = () => openChat(user);
                container.appendChild(card);
            });
            
            if (otherUsers.length === 0) {
                container.innerHTML = '<div class="empty-state">Nema drugih aktivnih korisnika</div>';
            }
            
            loading.style.display = 'none';
            container.style.display = 'grid';
        }
        
        function openChat(username) {
            sessionStorage.setItem('chatWith', username);
            window.location.href = 'chat.jsp';
        }
        
        function handleLogout() {
            sessionStorage.clear();
            window.location.href = 'login.jsp';
        }
        
        function showError(msg) {
            const errorDiv = document.getElementById('error');
            errorDiv.textContent = msg;
            errorDiv.style.display = 'block';
        }
        
        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }
    </script>
</body>
</html>
