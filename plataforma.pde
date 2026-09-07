class Plataforma {
  PVector pos;
  float ancho;
  float alto;
  color colorBase;
  color colorBorde;

  // Constructor mejorado: cada plataforma decide su propio tamaño al nacer
  Plataforma(float x, float y) {
    this.pos = new PVector(x, y);
    
    // Cada plataforma tendrá dimensiones únicas dentro de un rango cómodo para saltar
    this.ancho = random(80, 150);  // Un poco más anchas para facilitar el gameplay
    this.alto = random(20, 40);    // Más delgadas (estilo plataforma flotante de Mario)
    
    // Paleta de colores estilo tierra/ladrillo
    this.colorBase = color(180, 85, 40);  
    this.colorBorde = color(100, 40, 15);
  }

  void mostrar() {
    // 1. Sombra proyectada (Efecto de profundidad sutil)
    noStroke();
    fill(0, 0, 0, 40); // Negro con mucha transparencia
    rect(pos.x + 5, pos.y + 7, ancho, alto, 6);

    // 2. Cuerpo de la plataforma con bordes redondeados
    stroke(colorBorde);
    strokeWeight(3); // Borde grueso estilo cartoon
    fill(colorBase);
    rect(pos.x, pos.y, ancho, alto, 6); // El '6' suaviza las esquinas

    // 3. Detalle visual superior (Césped o relieve iluminado)
    noStroke();
    fill(255, 255, 255, 60); // Brillo superior
    rect(pos.x + 3, pos.y + 3, ancho - 6, 5, 2);
    
    // Restaurar grosor de línea por defecto para no alterar otros dibujos del juego
    strokeWeight(1); 
  }
}
