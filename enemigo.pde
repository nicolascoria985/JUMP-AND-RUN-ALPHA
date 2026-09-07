class Enemigo {
  float x, y;
  float radio;
  float velocidadX;
  PImage sprite;
  
  // Guardamos los límites de la plataforma donde camina para no caerse
  float limiteIzquierdo;
  float limiteDerecho;
  
  // El constructor ahora recibe la plataforma sobre la que va a patrullar
  Enemigo(float xInicial, float yInicial, float radioInicial, float inicioPlat, float anchoPlat) {
    x = xInicial;
    y = yInicial;
    radio = radioInicial;
    velocidadX = 1.5; // Una velocidad prudente para que Mario pueda esquivarlo
    
    // Definimos su zona de caminata (un poco hacia adentro para que no quede en el aire)
    limiteIzquierdo = inicioPlat + radio;
    limiteDerecho = inicioPlat + anchoPlat - radio;
    
    sprite = loadImage("enemigo(2).png");
  }
  
  void actualizar() {
    x += velocidadX;
    
    // Si llega al borde izquierdo o derecho de SU plataforma, da la vuelta
    if (x <= limiteIzquierdo) {
      x = limiteIzquierdo;
      velocidadX *= -1;
    }
    if (x >= limiteDerecho) {
      x = limiteDerecho;
      velocidadX *= -1;
    }
  }
  
 void dibujar() {
  if (sprite != null) {
    pushStyle();
    imageMode(CORNER); 
    // Dibuja el PNG centrado usando el radio
    image(sprite, x - radio, y - radio * 2, radio * 2, radio * 2);
    popStyle();
  } else {
    fill(150, 0, 255);
    ellipse(x, y - radio, radio * 2, radio * 2);
  }
}

}
