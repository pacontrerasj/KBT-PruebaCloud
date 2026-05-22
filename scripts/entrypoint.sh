#!/bin/sh
cat > /usr/share/nginx/html/index.html << HTML
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Technova Solutions</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; text-align: center; margin: 0; padding: 0; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); max-width: 500px; }
        h1 { color: #2c3e50; margin-bottom: 10px; }
        h2 { color: #764ba2; margin-top: 0; font-weight: 400; }
        .info { background: #f8f9fa; padding: 20px; border-radius: 10px; margin-top: 20px; }
        .info p { margin: 10px 0; color: #555; }
        .highlight { color: #764ba2; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Technova Solutions</h1>
        <h2>Alta Disponibilidad</h2>
        <div class="info">
            <p>Instancia: <span class="highlight">${INSTANCE_ID:-unknown}</span></p>
            <p>Zona: <span class="highlight">${AZ:-unknown}</span></p>
            <p>Version: <span class="highlight">${APP_VERSION:-latest}</span></p>
        </div>
    </div>
</body>
</html>
HTML
nginx -g "daemon off;"
