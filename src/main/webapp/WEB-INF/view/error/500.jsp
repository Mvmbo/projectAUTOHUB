<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="it">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Errore del server – AutoHUB</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Montserrat:wght@300;400;600&display=swap" rel="stylesheet">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body {
      font-family: 'Montserrat', sans-serif;
      background: #0a0a0a;
      color: #ccc;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .error-container { text-align: center; padding: 2rem; }
    .error-code {
      font-family: 'Playfair Display', serif;
      font-size: 8rem;
      color: #ff6b6b;
      font-weight: 700;
      line-height: 1;
    }
    .error-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.8rem;
      color: #fff;
      margin: 1rem 0 0.5rem;
      letter-spacing: 3px;
    }
    .error-message { color: #666; font-size: 0.9rem; margin-bottom: 2rem; }
    .btn-home {
      display: inline-block;
      background: linear-gradient(135deg, #D4AF37, #B8941F);
      color: #000;
      padding: 14px 32px;
      text-decoration: none;
      font-weight: 600;
      font-size: 0.82rem;
      letter-spacing: 2px;
      text-transform: uppercase;
      border-radius: 2px;
      transition: all 0.3s ease;
    }
    .btn-home:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(212,175,55,0.3);
    }
  </style>
</head>
<body>
  <div class="error-container">
    <div class="error-code">500</div>
    <h1 class="error-title">ERRORE DEL SERVER</h1>
    <p class="error-message">Si è verificato un problema. Riprova più tardi.</p>
    <a href="${pageContext.request.contextPath}/home" class="btn-home">Torna alla Home</a>
  </div>
</body>
</html>
