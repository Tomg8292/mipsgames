# 🏎️ Tracker Race - Documentación Extendida de Funciones (MIPS Assembly)

## 📘 Descripción general

Este documento resume todas las funciones principales del juego
**Tracker Race**, escritas en ensamblador MIPS. Cada rutina se documenta
con sus argumentos, registros usados, dependencias y propósito.

------------------------------------------------------------------------

## 🧩 Funciones principales

  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  **Función**                 **Argumentos**             **Registros   **Qué hace / Descripción       **Llamada por**          **Llama a**                **Notas / Detalles útiles**
                                                         usados**      detallada**                                                                        
  --------------------------- -------------------------- ------------- ------------------------------ ------------------------ -------------------------- -----------------------------------------
  **fillScreen**              `$a0 = base VRAM`,         `$t0–$t2`     Rellena toda la memoria de     `clearScreen`,           ---                        Loop simple que escribe 8192 palabras.
                              `$a1 = color`                            video con un color uniforme    `startGame`                                         
                                                                       (8192 palabras → pantalla                                                          
                                                                       64×128).                                                                           

  **clearScreen**             ---                        `$a0–$a1`,    Limpia toda la pantalla (color Menú, reinicio           `fillScreen`               Ideal para reinicializar escenas o
                                                         `$ra`         negro). Guarda `$ra`, llama a                                                      pantallas entre estados.
                                                                       `fillScreen`, y retorna.                                                           

  **setPixel**                `$a0 = X`, `$a1 = Y`,      `$t0–$t1`     Dibuja un píxel en pantalla    Casi todas las funciones ---                        Usa desplazamientos optimizados
                              `$a2 = color`                            con clipping (0 ≤ X \< 64, 0 ≤ gráficas                                            (`Y * 64 * 4`).
                                                                       Y \< 128).                                                                         

  **updateScroll**            ---                        `$t0–$t2`     Controla el desplazamiento     `drawTrack`, `loop`,     ---                        Efecto de movimiento continuo.
                                                                       vertical del fondo. Incrementa `menuLoop`                                          
                                                                       `scrollOffset` según                                                               
                                                                       `carSpeed`.                                                                        

  **drawTrack**               ---                        `$t9`,        Dibuja la pista completa en 3  `menuLoop`, `loop`       `drawPista64Simple`        Simula pista infinita.
                                                         `$a0–$a1`,    bloques de 64 px (arriba,                                                          
                                                         `$ra`         centro, abajo).                                                                    

  **drawPista64Simple**       `$a0 = X`, `$a1 = Y`       `$s0–$s5`,    Dibuja bloque 64×64 del fondo. `drawTrack`              `setPixel`                 Copia píxeles de `pista64_data`.
                                                         `$t0–$t3`     Usa alpha para borrar fondo.                                                       

  **drawCarSprite32**         `$a0 = X centro`,          `$s0–$s5`,    Dibuja el auto principal       `menuLoop`, `loop`       `setPixel`                 Sprite principal del jugador.
                              `$a1 = Y top`              `$t5–$t9`     (32×32) con transparencia.                                                         

  **drawObstacle**            `$a0 = X`, `$a1 = Y`       `$s6–$s7`,    Dibuja obstáculos según        `loop`                   `drawSprite16Scaled`       Usa sprites escalados 16×16.
                                                         `$t0`         `obsType`.                                                                         

  **drawSprite16Scaled**      `$a0 = X`, `$a1 = Y`,      `$s0–$s6`,    Dibuja sprite 32×32 escalado a `drawObstacle`           `setPixel`                 Ideal para ítems/obstáculos.
                              `$a2 = sprite`             `$t0–$t9`     16×16.                                                                             

  **drawExplosion**           `$a0 = X`, `$a1 = Y`       `$s0–$s5`,    Dibuja animación de explosión  `loop`,                  ---                        Movimiento sincronizado con velocidad del
                                                         `$t0–$t9`     (16×16, con alpha).            `normalCollisionMulti`                              auto.

  **initObstacles**           ---                        `$t0–$t9`     Inicializa listas de           `startGame`              ---                        Prepara el sistema de obstáculos.
                                                                       obstáculos                                                                         
                                                                       (`obstaclesX/Y/Type/Active`) a                                                     
                                                                       cero.                                                                              

  **trySpawnObstacle**        ---                        `$t0–$t9`,    Spawnea nuevo obstáculo si hay `loop`                   `getRandom`,               Controla frecuencia y tipo.
                                                         `$s0–$s7`     espacio.                                                `getInitialLane`           

  **getInitialLane**          `$a0 = índice obstáculo`   `$v0`,        Devuelve carril inicial (0, 1  `trySpawnObstacle`       `getRandom`                Evita carriles consecutivos iguales.
                                                         `$t0–$t5`     o 2) evitando repeticiones.                                                        

  **getRandom**               `$a0 = máximo`             `$v0`,        Generador congruencial lineal  `trySpawnObstacle`,      ---                        `(seed * 1103515245 + 12345) mod 2^31`.
                                                         `$t0–$t3`     pseudoaleatorio.               `getInitialLane`                                    

  **drawHearts**              ---                        `$s0–$s3`,    Dibuja los corazones de vida   `loop`                   `setPixel`                 Corazones rojos o grises según vidas.
                                                         `$t7–$t9`     (hasta 3).                                                                         

  **drawScore**               ---                        `$t0–$t9`     Muestra el puntaje en          `loop`                   `drawDigit`                Divide número por 10 para extraer
                                                                       pantalla.                                                                          dígitos.

  **drawDigit**               `$a0 = X`, `$a1 = Y`,      `$t0–$t9`     Dibuja un dígito 3×5 con       `drawScore`              `setPixel`                 Usa patrones internos.
                              `$a2 = dígito`                           `setPixel`.                                                                        

  **checkCollision**          ---                        `$t0–$t9`,    Verifica colisiones entre auto `loop`                   `charcoCollisionMulti`,    Calcula hitboxes rectangulares.
                                                         `$s1–$s4`     y obstáculos.                                           `powerupCollisionMulti`,   
                                                                                                                               `normalCollisionMulti`     

  **charcoCollisionMulti**    ---                        `$t0–$t4`     Activa ralentización           `checkCollision`         ---                        `carSpeed = 0`, dura 30 frames.
                                                                       (`slowdownActive=1`).                                                              

  **powerupCollisionMulti**   ---                        `$t0–$t4`     Mejora velocidad y vida.       `checkCollision`         ---                        Máx. 3 vidas, cancela slowdown.

  **normalCollisionMulti**    ---                        `$t0–$t9`     Resta vida, genera explosión.  `checkCollision`         `drawExplosion`            Si `lives = 0`, finaliza juego.
  -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------

## ⚙️ Variables clave

  -----------------------------------------------------------------------
  **Variable**                               **Uso**
  ------------------------------------------ ----------------------------
  `carSpeed`                                 Velocidad actual del auto
                                             (0--3).

  `slowdownActive`, `slowdownTimer`          Control del charco
                                             (ralentización).

  `lives`                                    Vidas restantes.

  `score`                                    Puntaje acumulado.

  `obstaclesX/Y/Active/Type`                 Posiciones y tipos de
                                             obstáculos.

  `explosionActive`, `explosionTimer`,       Estado y animación de
  `explosionX/Y`                             explosión.

  `scrollOffset`                             Desplazamiento vertical de
                                             fondo.
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## 🔗 Relaciones entre funciones

``` text
main
 ├── menuLoop
 │    ├── updateScroll → drawTrack
 │    ├── drawCarSprite32
 │    └── setPixel (texto menú)
 │
 └── startGame
      ├── fillScreen → initObstacles → loop
      └── loop
           ├── updateScroll → drawTrack → drawPista64Simple
           ├── drawObstacle → drawSprite16Scaled
           ├── drawCarSprite32
           ├── drawHUD → drawHearts, drawScore → drawDigit
           ├── checkCollision
           │     ├── charcoCollisionMulti
           │     ├── powerupCollisionMulti
           │     └── normalCollisionMulti → drawExplosion
           └── trySpawnObstacle → getInitialLane → getRandom
```

------------------------------------------------------------------------

