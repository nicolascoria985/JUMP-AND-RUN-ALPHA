// --- CAPTURA DE TECLADO (Pestaña Principal) ---
void keyPressed() {
  if (keyCode == LEFT || key == 'a')  izquierda = true;
  if (keyCode == RIGHT || key == 'd') derecha = true;
  if (keyCode == UP || key == ' ') {
    heroe.saltar(); // Llama directamente al método de salto en la clase Jugador
  }
}

void keyReleased() {
  if (keyCode == LEFT || key == 'a')  izquierda = false;
  if (keyCode == RIGHT || key == 'd') derecha = false;
}
