<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Chat Login</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 400px;
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            font-size: 28px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
        }
        button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: opacity 0.3s;
        }
        button:hover {
            opacity: 0.9;
        }
        .error {
            color: #d32f2f;
            text-align: center;
            margin-top: 15px;
            display: none;
        }
        .loading {
            display: none;
            text-align: center;
            margin-top: 15px;
            color: #667eea;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h1>Chat Login</h1>
        <div class="form-group">
            <label for="username">Korisničko Ime:</label>
            <input type="text" id="username" placeholder="Unesite vaše korisničko ime">
        </div>
        <button onclick="handleLogin()">Prijava</button>
        <div class="error" id="error"></div>
        <div class="loading" id="loading">Učitavanje...</div>
    </div>

    <script>
        function handleLogin() {
            const username = document.getElementById('username').value.trim();
            
            if (!username) {
                showError('Molimo unesite korisničko ime');
                return;
            }
            
            document.getElementById('loading').style.display = 'block';
            document.getElementById('error').style.display = 'none';
            
            fetch('http://10.2.1.32:8082/login', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({name: username})
            })
            .then(resp => {
                if (!resp.ok) throw new Error('Login greška');
                return resp.text();
            })
            .then(() => {
                sessionStorage.setItem('username', username);
                window.location.href = 'users.jsp';
            })
            .catch(err => {
                console.error('Login error:', err);
                showError('Greška pri prijavi. Pokušajte ponovo.');
                document.getElementById('loading').style.display = 'none';
            });
        }
        
        function showError(msg) {
            const errorDiv = document.getElementById('error');
            errorDiv.textContent = msg;
            errorDiv.style.display = 'block';
        }
        
        // Enter key support
        document.getElementById('username').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') handleLogin();
        });
    </script>
</body>
</html>
