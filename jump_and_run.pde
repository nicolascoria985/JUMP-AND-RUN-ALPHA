import java.util.ArrayList;

ArrayList<Plataforma> listaPlataformas = new ArrayList<Plataforma>(); // Lista dinámica para plataformas
ArrayList<Enemigo> listaEnemigos = new ArrayList<Enemigo>();       // Lista dinámica para enemigos

float proximaPlataformaX = 400; // Desde acá empieza la primera 

Jugador heroe;
PImage imgMario;
float gravedad = 0.4;

// Variables de la Cámara y Bucle
float camaraX = 0; 
float anchoSuelo = 400;
float anchoNubeBucle = 300;

// Variables globales para leer el teclado de manera fluida
boolean izquierda = false;
boolean derecha = false;

void setup() {
  size(800, 600);
  
  // Se carga la imagen del Mario para el pj
  imgMario = loadImage("mario sprite.png");

  // Iniciamos al héroe y limpiamos el mapa
  reiniciarJuego();
}

void draw() {
  background(135, 206, 235); // Cielo
  
  // --- ACTUALIZACIÓN DEL JUGADOR ---
  // Enviamos los estados de las teclas al cerebro de tu clase Jugador antes de actualizar sus físicas
  heroe.teclaIzquierda = izquierda;
  heroe.teclaDerecha = derecha;
  heroe.actualizar(gravedad);
 
  // --- SISTEMA DE CÁMARA ---
  if (heroe.x > width / 2) {
    camaraX = heroe.x - width / 2;
  }
  
  // --- NUBES EN BUCLE (PARALLAX) ---
  float camaraNubes = camaraX * 0.3;
  int nubeInicio = floor(camaraNubes / anchoNubeBucle);
  int nubesVisibles = ceil(width / anchoNubeBucle) + 1;
  
  pushMatrix();
  translate(-camaraNubes, 0);
  fill(255, 255, 255, 200);
  noStroke();
  for (int i = nubeInicio; i <= nubeInicio + nubesVisibles; i++) {
    float nubeX = i * anchoNubeBucle;
    ellipse(nubeX + 50,  100, 60, 50);
    ellipse(nubeX + 80,  90,  80, 60);
    ellipse(nubeX + 110, 100, 60, 50);
    ellipse(nubeX + 200, 150, 70, 45);
    ellipse(nubeX + 230, 145, 90, 55);
  }
  popMatrix();
  stroke(0);
  
  // --- ESCENARIO Y JUGADOR (MUNDO REAL) ---
  heroe.enElSuelo = false; 
  int bloqueInicio = floor(camaraX / anchoSuelo);
  int bloquesVisibles = ceil(width / anchoSuelo) + 1;
  
  pushMatrix();
  translate(-camaraX, 0);
  
  // A. Dibujar Suelo verde continuo
  fill(34, 139, 34); 
  for (int i = bloqueInicio; i <= bloqueInicio + bloquesVisibles; i++) {
    float sueloX = i * anchoSuelo;
    float sueloY = 500;
    float sueloAlto = 100;
    
    rect(sueloX, sueloY, anchoSuelo, sueloAlto);
    heroe.verificarColisionSuelo(sueloX, sueloY, anchoSuelo);
  }
  
  // B. Controlar, dibujar y hacer chocar la lista de plataformas flotantes
  for (int i = listaPlataformas.size() - 1; i >= 0; i--) {
    Plataforma plat = listaPlataformas.get(i);
    plat.mostrar(); // Dibuja la plataforma actual
    
    // Si las coordenadas de las plataformas coinciden con las nuestras, rebotamos en ellas
    heroe.verificarColisionSuelo(plat.pos.x, plat.pos.y, plat.ancho);
    
    // Si nos quedamos muy lejos de una plataforma, esta se borra
    if (plat.pos.x < camaraX - 200) {
      listaPlataformas.remove(i);
    }
  }
  
  // C. Controlar, actualizar y combatir con la lista de enemigos
  for (int i = listaEnemigos.size() - 1; i >= 0; i--) {
    Enemigo ene = listaEnemigos.get(i);
    ene.actualizar();
    ene.dibujar();
    
    // --- SISTEMA DE COMBATE (LOGICA B: DISTANCIA RADIAL) ---
    float marioCentroX = heroe.x + (heroe.ancho / 2);
    float marioCentroY = heroe.y + (heroe.alto / 2);
    
    float distancia = dist(marioCentroX, marioCentroY, ene.x, ene.y);
    float radioMario = heroe.ancho / 2; 
    
    if (distancia < (radioMario + ene.radio)) {
      // ¿Mario está cayendo y sus pies están por encima del centro del enemigo?
      if (heroe.velY > 0 && (heroe.y + heroe.alto) < ene.y + 10) {
        listaEnemigos.remove(i); // Eliminamos al enemigo (¡Aplastado!)
        heroe.velY = -9;         // Mario rebota hacia arriba con fuerza
        heroe.enElSuelo = false;
      } 
      // Si no cayó desde arriba, el enemigo golpea a Mario
      else {
        heroe.recibirDano(); 
      }
    }
    // Si el enemigo se queda muy atrás de la cámara, se borra para ahorrar memoria
    else if (ene.x < camaraX - 200) {
      listaEnemigos.remove(i);
    }
  }
  
  // D. Generación infinita de plataformas hacia adelante
  if (proximaPlataformaX < camaraX + width + 400) {
    crearNuevaPlataforma();
  }
  
  // E. Control de Caída al Vacío
  if (heroe.y > height + 100) {
    heroe.vidas = 0; // Si cae abajo de la pantalla, pierde directo
  }
  
  // Nuestro personaje se superpone ante todo en el espacio del mapa
  heroe.dibujar(imgMario);
  
  popMatrix();
  
  // --- INTERFAZ DE USUARIO FIJA (HUD) ---
  textSize(24);
  fill(255);
  stroke(0);
  strokeWeight(4);
  text("VIDAS: " + heroe.vidas, 20, 40);
  
  // Mensaje en pantalla si pierdes todas las vidas
  if (heroe.vidas <= 0) {
    fill(0, 0, 0, 180); // Fondo oscuro traslúcido
    rect(0, 0, width, height);
    
    fill(255, 50, 50);
    textSize(50);
    textAlign(CENTER, CENTER);
    text("GAME OVER", width / 2, height / 2 - 20);
    
    fill(255);
    textSize(20);
    text("Presiona 'R' para volver a jugar", width / 2, height / 2 + 40);
    textAlign(LEFT, BASELINE); // Restaurar alineación estándar de Processing
    noLoop(); // Pausa el bucle principal
  }
}

// Con esto creamos las plataformas en posiciones aleatorias y distribuimos enemigos
void crearNuevaPlataforma() {
  float aleatorioY = random(300, 450); // alturas (accesibles para el jugador)
  Plataforma nuevaPlat = new Plataforma(proximaPlataformaX, aleatorioY);
  listaPlataformas.add(nuevaPlat);
  
  // 70% de probabilidad de que aparezca un enemigo patrullando encima
  if (random(100) < 60) {
    float puntoMedioX = nuevaPlat.pos.x + (nuevaPlat.ancho / 2);
    float radioEnemigo = 15;
    Enemigo nuevoEne = new Enemigo(puntoMedioX, nuevaPlat.pos.y, radioEnemigo, nuevaPlat.pos.x, nuevaPlat.ancho);
    listaEnemigos.add(nuevoEne);
  }
  
  proximaPlataformaX += random(250, 350); 
}

// Función auxiliar estructurada para resetear valores
void reiniciarJuego() {
  listaPlataformas.clear();
  listaEnemigos.clear();
  proximaPlataformaX = 400;
  camaraX = 0;
  izquierda = false;
  derecha = false;
  
  heroe = new Jugador(100, 300); 
  
  for(int i = 0; i < 5; i++) {
    crearNuevaPlataforma();
  }
  loop(); // Reanuda el draw() si estaba pausado
}
