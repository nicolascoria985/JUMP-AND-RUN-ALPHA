class Jugador {
  // Propiedades básicas
  float x, y;
  float ancho, alto;
  float velX, velY;
  
  // --- NUEVAS PROPIEDADES DE JUEGO ---
  int vidas;
  boolean invencible;
  int tiempoInvencible; // Contador de fotogramas para la inmunidad
  
  // Físicas pulidas
  float velocidadMaxima = 6;
  float aceleracion = 0.5;
  float friccion = 0.85;
  float impulsoSalto = -11.5;
  boolean enElSuelo;
  
  // Dirección para orientar el Sprite (1 = Derecha, -1 = Izquierda)
  int direccion = 1; 
  
  // Estados de control (El "cerebro" interno que escucha a la pestaña principal)
  boolean teclaIzquierda = false;
  boolean teclaDerecha = false;
  
  // Constructor
  Jugador(float xInicial, float yInicial) {
    x = xInicial;
    y = yInicial;
    
    // Dimensiones unificadas (coinciden exactamente con el dibujo y la colisión)
    ancho = 40;
    alto = 55;
    
    velX = 0;
    velY = 0;
    enElSuelo = false;
    
    // --- INICIALIZACIÓN DE VIDAS ---
    this.vidas = 3;
    this.invencible = false;
    this.tiempoInvencible = 0;
  }
  
  // Procesa movimiento y físicas con inercia (Suavizado de movimiento)
  void actualizar(float gravedad) {
    // 1. Movimiento horizontal con aceleración gradual (Estilo Mario original)
    if (teclaIzquierda) {
      velX -= aceleracion;
      direccion = -1; // Apunta a la izquierda
    } else if (teclaDerecha) {
      velX += aceleracion;
      direccion = 1;  // Apunta a la derecha
    } else {
      velX *= friccion; // Se detiene suavemente si dejas de presionar
    }
    
    // Limitar velocidad máxima para que no acelere infinitamente
    velX = constrain(velX, -velocidadMaxima, velocidadMaxima);
    x += velX;
    
    // Evitar que el jugador regrese más allá del inicio de la pantalla izquierda
    if (x < 0) {
      x = 0;
      velX = 0;
    }
    
    // 2. Aplicamos gravedad y límite de caída libre (Evita atravesar plataformas por ir muy rápido)
    velY += gravedad;
    velY = constrain(velY, -20, 15); 
    y += velY;
    
    // --- CONTROL DE INVENCIBILIDAD ---
    if (invencible) {
      tiempoInvencible--;
      if (tiempoInvencible <= 0) {
        invencible = false;
      }
    }
  }
  
  // Dibuja al personaje y lo voltea según hacia dónde camina
  void dibujar(PImage img) {
    // Si es invencible, hacemos que parpadee (se dibuja un fotograma sí y otro no)
    if (invencible && frameCount % 6 < 3) {
      return; // Salta este fotograma de dibujo para simular parpadeo
    }
    
    pushMatrix();
    
    if (img != null) {
      // Efecto espejo: Si va a la izquierda, voltea la imagen horizontalmente
      if (direccion == -1) {
        translate(x + ancho, y);
        scale(-1, 1);
        image(img, 0, 0, ancho, alto);
      } else {
        translate(x, y);
        image(img, 0, 0, ancho, alto);
      }
    } else {
      // Cuadrado de respaldo por si falla el archivo de imagen
      translate(x, y);
      fill(220, 50, 50); 
      stroke(0);
      strokeWeight(2);
      rect(0, 0, ancho, alto, 4);
    }
    
    popMatrix();
  }
  
  // Lógica interna para ejecutar el salto
  void saltar() {
    if (enElSuelo) {
      velY = impulsoSalto;
      enElSuelo = false;
    }
  }
  
  // Lógica de colisiones ultra precisa (evita que tiemble o se caiga de los bordes)
  void verificarColisionSuelo(float sueloX, float sueloY, float sueloAncho) {
    // Verificación horizontal (¿Está alineado con la plataforma?)
    if (x + ancho > sueloX && x < sueloX + sueloAncho) {
      // Verificación vertical (¿Está cayendo y sus pies tocan la superficie?)
      if (velY >= 0 && y + alto >= sueloY && y + alto <= sueloY + velY + 4) {
        y = sueloY - alto; // Reposicionar exactamente arriba del suelo
        velY = 0;
        enElSuelo = true;
      }
    }
  }
  
  // --- MÉTODO NUEVO: RECIBIR DAÑO ---
  void recibirDano() {
    if (!invencible) {
      vidas--;
      invencible = true;
      tiempoInvencible = 60; // 1 segundo de inmunidad (60 fotogramas)
      velY = -6; // Pequeño empuje hacia arriba al ser golpeado (estilo retro)
    }
  }
}
