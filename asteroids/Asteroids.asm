.data
    display: .word 0x10008000
    display_back: .word 0x10040000
    
    # Colores del men� en formato 0x00RRGGBB
    negro: .word 0x00000000
    color1: .word 0x00847e87    # Gris violeta
    blanco: .word 0x00FFFFFF
    color3: .word 0x00696a6a    # Gris oscuro
    color4: .word 0x009badb7    # Celeste gris�ceo
    color5: .word 0x00ac3232    # ROJO FUERTE
    color6: .word 0x00fbf236    # Amarillo fuerte
    
    # Colores de los asteroides
    azul: .word 0x000088FF
    rojo: .word 0x00FF0000
    verde: .word 0x0000FF00
    amarillo: .word 0x00FFFF00
    naranja: .word 0x00FF8800
    
    # NUEVOS COLORES PARA ASTEROIDES
    ast_marron_claro: .word 0x008f563b   # Marr�n claro (#8f563b)
    ast_marron_oscuro: .word 0x00663931  # Marr�n oscuro (#663931)
    
    # NUEVA PALETA PARA LA NAVE (nombres �nicos)
    nave_color_0: .word 0x00000000   # Negro
    nave_color_1: .word 0x00847e87   # Gris�ceo
    nave_color_2: .word 0x00595652   # Gris marr�n
    nave_color_3: .word 0x00323c39   # Gris oscuro
    nave_color_4: .word 0x00639bff   # Celeste
    nave_color_5: .word 0x00ac3232   # Rojo
    
    # Sprites de la nave (8 direcciones, cada una 5x5 = 25 bytes)
    nave_sprites:
        # Direcci�n 0: Derecha (?) - SPRITE NUEVO
        .byte 0,2,0,0,0
        .byte 5,0,2,1,0
        .byte 0,1,3,4,1
        .byte 5,0,2,1,0
        .byte 0,2,0,0,0
        
        # Direcci�n 1: Diagonal superior derecha (?) - CORRECTO
        .byte 0,0,0,1,1
        .byte 0,2,2,4,1
        .byte 5,0,3,2,0
        .byte 0,0,0,2,0
        .byte 0,0,5,0,0
        
        # Direcci�n 2: Arriba (?) - CORRECTO
        .byte 0,0,1,0,0
        .byte 0,1,4,1,0
        .byte 0,2,3,2,0
        .byte 2,0,1,0,2
        .byte 0,5,0,5,0
        
        # Direcci�n 3: Diagonal superior izquierda (?) - CORRECTO
        .byte 1,1,0,0,0
        .byte 1,4,2,2,0
        .byte 0,2,3,0,5
        .byte 0,2,0,0,0
        .byte 0,0,5,0,0
        
        # Direcci�n 4: Izquierda (?) - SPRITE NUEVO
        .byte 0,0,0,2,0
        .byte 0,1,2,0,5
        .byte 1,4,3,1,0
        .byte 0,1,2,0,5
        .byte 0,0,0,2,0
        
        # Direcci�n 5: Diagonal inferior izquierda (?) - SPRITE CORREGIDO
        .byte 0,0,5,0,0
        .byte 0,2,0,0,0
        .byte 0,2,3,0,5
        .byte 1,4,2,2,0
        .byte 1,1,0,0,0
        
        # Direcci�n 6: Abajo (?) - SPRITE NUEVO
        .byte 0,5,0,5,0
        .byte 2,0,1,0,2
        .byte 0,2,3,2,0
        .byte 0,1,4,1,0
        .byte 0,0,1,0,0
        
        # Direcci�n 7: Diagonal inferior derecha (?) - CORRECTO
        .byte 0,0,5,0,0
        .byte 0,0,0,2,0
        .byte 5,0,3,2,0
        .byte 0,2,2,4,1
        .byte 0,0,0,1,1
    
    # ==========================================
    # NUEVOS SPRITES DE ASTEROIDES
    # ==========================================
    
    # Asteroide GRANDE (8x8 = 64 bytes)
    # 0: transparente, 1: marr�n claro, 2: marr�n oscuro
    asteroide_grande_sprite:
        .byte 0,0,1,1,1,1,0,0
        .byte 0,1,1,2,2,1,1,0
        .byte 1,1,2,1,2,2,1,1
        .byte 1,2,2,2,2,2,2,1
        .byte 1,2,2,2,2,1,2,1
        .byte 1,1,2,1,2,2,1,1
        .byte 0,1,1,2,2,1,1,0
        .byte 0,0,1,1,1,1,0,0
    
    # Asteroide MEDIANO (5x5 = 25 bytes)
    asteroide_mediano_sprite:
        .byte 0,1,1,1,0
        .byte 1,2,2,1,1
        .byte 1,2,1,2,1
        .byte 1,1,2,2,1
        .byte 0,1,1,1,0
    
    # Asteroide PEQUE�O (3x3 = 9 bytes)
    asteroide_pequeno_sprite:
        .byte 1,1,0
        .byte 1,2,1
        .byte 0,1,1
    
    # Variables de la nave rotable
    nave_x: .word 32
    nave_y: .word 32
    nave_angulo: .word 2  # 0-7 (0=derecha, 2=arriba inicialmente)
    nave_velocidad: .word 1
    
    asteroides: .space 400
    num_ast: .word 0
    frames: .word 0
    seed: .word 12345
    
    vidas: .word 3
    game_over: .word 0
    invulnerable: .word 0
    invul_frames: .word 0
    
    # Variables para el sistema de disparo
    balas: .space 200  # Espacio para 10 balas (20 bytes cada una: x, y, dx, dy, activa)
    num_balas: .word 0
    max_balas: .word 10

    # Mapa del men� (64x64 pixels)
    menu_map:
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,2,2,2,0,0,0,2,2,2,2,0,0,2,2,2,2,2,0,0,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,2,1,1,1,2,0,2,1,1,1,0,0,1,1,1,2,1,0,0,1,2,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,2,0,0,1,2,0,2,0,0,0,0,0,0,0,1,2,0,0,0,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,2,2,2,2,2,0,1,2,2,2,0,0,0,0,1,2,0,0,0,1,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,2,1,1,1,2,0,0,1,1,1,2,0,0,0,1,2,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,2,0,0,1,2,0,0,0,0,0,2,0,0,0,1,2,0,0,0,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,2,0,0,1,2,0,2,2,2,2,0,0,0,0,1,2,0,0,0,1,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,0,0,0,1,0,0,1,1,1,1,0,0,0,0,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,0,0,2,2,2,2,2,0,0,2,0,0,2,2,2,0,0,0,0,2,2,2,2,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,1,1,2,0,1,2,1,1,1,2,0,1,2,0,1,2,1,1,2,0,0,2,1,1,1,0,0,0,0,0,0
        .byte 0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,0,1,2,0,2,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,1,1,4,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,2,2,0,0,1,2,0,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,2,2,0,0,0,0,0,0
        .byte 0,0,0,0,0,4,4,3,1,1,3,0,0,0,6,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,1,2,1,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,0,1,2,0,0,1,1,1,2,0,0,0,0,0
        .byte 0,0,0,0,0,4,4,3,1,1,3,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,0,0,6,0,0,1,2,0,1,2,0,1,2,0,0,1,2,0,1,2,0,1,2,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0
        .byte 0,0,0,0,0,1,1,4,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2,0,1,2,0,1,2,2,2,2,2,0,1,2,0,1,2,2,2,1,0,0,2,2,2,2,0,0,0,0,0,0
        .byte 0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,1,1,1,1,0,0,1,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,6,6,0,0,6,6,0,0,6,6,6,0,0,6,6,0,0,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,6,0,6,0,6,0,6,0,6,6,0,0,6,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,6,6,0,0,6,6,0,0,6,0,0,0,0,6,6,0,0,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,6,0,6,0,6,6,6,0,6,6,0,0,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,0,6,6,6,0,0,6,0,0,6,6,0,0,6,6,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,6,0,0,6,0,6,0,6,0,6,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,0,0,6,0,0,6,6,6,0,6,6,0,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,0,0,0,6,0,0,6,0,6,0,6,0,6,0,0,6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        
 # Mapa del Game Over (64x64 pixels) - "GG" en rojo centrado
game_over_map:
    # Las primeras 20 filas vac�as
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
    # Fila 20: Primera "G" (columna 20-26)
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,0,0,5,5,5,5,5,0,0,5,5,0,5,5,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,0,0,0,5,0,0,5,0,5,0,5,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,5,5,5,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,5,5,5,5,5,0,0,5,0,0,0,5,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
    # Fila 27: Segunda "G" (columna 35-41)
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,0,5,0,0,0,5,0,0,5,5,5,5,5,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,5,5,5,5,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,5,0,0,0,5,0,0,5,0,0,0,0,0,0,5,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,0,0,0,5,0,0,0,5,0,5,0,0,0,5,0,0,0,0,0,0,5,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,0,0,0,0,5,0,0,0,0,5,5,5,5,5,0,0,5,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    
    
    # Las filas restantes vac�as
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.text
main:
    li $sp, 0x7ffffffc
    
    # Mostrar men� principal con sprite
    jal mostrar_menu_principal
    
    # Esperar a que presionen Enter
    jal esperar_enter
    
    # Iniciar juego
    j iniciar_juego

mostrar_menu_principal:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar y dibujar sprite completo
    jal limpiar_back_buffer
    jal dibujar_sprite_menu_completo
    jal swap_buffers
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

dibujar_sprite_menu_completo:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)  # dirección del mapa
    sw $s1, 8($sp)   # coordenada Y
    sw $s2, 4($sp)   # coordenada X  
    sw $s3, 0($sp)   # valor del pixel
    
    la $s0, menu_map
    li $s1, 0        # Y = 0
    
dibujar_sprite_y:
    li $s2, 0        # X = 0
    
dibujar_sprite_x:
    # Calcular posición en el array: Y * 64 + X
    sll $t0, $s1, 6    # Y * 64
    addu $t0, $t0, $s2  # + X
    addu $t1, $s0, $t0  # dirección del byte
    
    lb $s3, 0($t1)      # leer valor del pixel
    
    # Si no es 0, dibujar el pixel
    beqz $s3, sprite_siguiente
    
    move $a0, $s2       # coordenada X
    move $a1, $s1       # coordenada Y
    move $a2, $s3       # código de color
    
    jal obtener_color_sprite
    move $a2, $v0       # color real
    
    jal pixel_back

sprite_siguiente:
    addiu $s2, $s2, 1
    li $t0, 64
    blt $s2, $t0, dibujar_sprite_x
    
    addiu $s1, $s1, 1
    li $t0, 64
    blt $s1, $t0, dibujar_sprite_y
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

obtener_color_sprite:
    li $v0, 0
    beq $a2, 1, color_sprite_1
    beq $a2, 2, color_sprite_2
    beq $a2, 3, color_sprite_3
    beq $a2, 4, color_sprite_4
    beq $a2, 5, color_sprite_5
    beq $a2, 6, color_sprite_6
    jr $ra
    
color_sprite_1: 
    lw $v0, color1 
    jr $ra
color_sprite_2: 
    lw $v0, blanco
    jr $ra
color_sprite_3: 
    lw $v0, color3
    jr $ra
color_sprite_4: 
    lw $v0, color4
    jr $ra
color_sprite_5: 
    lw $v0, color5
    jr $ra
color_sprite_6: 
    lw $v0, color6
    jr $ra

esperar_enter:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
esperar_enter_loop:
    # Leer teclado
    lui $t0, 0xffff
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, esperar_enter_loop
    
    lw $t2, 4($t0)
    li $t3, 10        # Código ASCII para Enter
    beq $t2, $t3, esperar_enter_fin
    
    j esperar_enter_loop

esperar_enter_fin:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
    
# ==========================================
# NUEVAS FUNCIONES PARA DIBUJAR ASTEROIDES CON SPRITES
# ==========================================

# Funci�n para obtener color del asteroide
obtener_color_asteroide:
    # $a2: c�digo de color (1 o 2)
    beq $a2, 1, color_ast_1
    beq $a2, 2, color_ast_2
    lw $v0, negro
    jr $ra
    
color_ast_1:
    lw $v0, ast_marron_claro
    jr $ra
color_ast_2:
    lw $v0, ast_marron_oscuro
    jr $ra

iniciar_juego:
    # Reiniciar variables del juego
    li $t0, 3
    sw $t0, vidas
    sw $zero, game_over
    sw $zero, invulnerable
    sw $zero, invul_frames
    sw $zero, num_ast
    sw $zero, frames
    
    # Posición inicial de la nave
    li $t0, 32
    sw $t0, nave_x
    li $t0, 32
    sw $t0, nave_y
    li $t0, 2
    sw $t0, nave_angulo

game_loop:
    lw $t0, game_over
    bnez $t0, fin_juego
    
    jal actualizar_invulnerabilidad
    jal limpiar_back_buffer
    jal teclas
    jal mover_asteroides
    jal mover_balas
    jal crear_asteroide
    jal dibujar_nave_back
    jal dibujar_asteroides_back
    jal dibujar_balas_back
    jal dibujar_vidas_back
    jal verificar_colisiones
    jal verificar_colisiones_balas
    jal swap_buffers
    jal esperar
    j game_loop

fin_juego:
    jal mostrar_pantalla_game_over
    jal esperar_enter  # Esperar a que presionen Enter
    j main           # Volver al menú principal

mostrar_pantalla_game_over:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Limpiar y dibujar sprite completo del Game Over
    jal limpiar_back_buffer
    jal dibujar_sprite_game_over
    jal swap_buffers
    
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

dibujar_sprite_game_over:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)  # dirección del mapa
    sw $s1, 8($sp)   # coordenada Y
    sw $s2, 4($sp)   # coordenada X  
    sw $s3, 0($sp)   # valor del pixel
    
    la $s0, game_over_map
    li $s1, 0        # Y = 0
    
dibujar_game_over_y:
    li $s2, 0        # X = 0
    
dibujar_game_over_x:
    # Calcular posición en el array: Y * 64 + X
    sll $t0, $s1, 6    # Y * 64
    addu $t0, $t0, $s2  # + X
    addu $t1, $s0, $t0  # dirección del byte
    
    lb $s3, 0($t1)      # leer valor del pixel
    
    # Si no es 0, dibujar el pixel
    beqz $s3, game_over_siguiente
    
    move $a0, $s2       # coordenada X
    move $a1, $s1       # coordenada Y
    move $a2, $s3       # código de color
    
    jal obtener_color_sprite
    move $a2, $v0       # color real
    
    jal pixel_back

game_over_siguiente:
    addiu $s2, $s2, 1
    li $t0, 64
    blt $s2, $t0, dibujar_game_over_x
    
    addiu $s1, $s1, 1
    li $t0, 64
    blt $s1, $t0, dibujar_game_over_y
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra



# ==========================================
# NAVE CON SPRITES - NUEVA IMPLEMENTACIÓN
# ==========================================
dibujar_nave_back:
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)  # ángulo de la nave
    sw $s1, 8($sp)   # dirección base del sprite
    sw $s2, 4($sp)   # coordenada Y del sprite
    sw $s3, 0($sp)   # coordenada X del sprite
    
    # Verificar si está en modo invulnerable (parpadeo)
    lw $t0, invulnerable
    beqz $t0, dibujar_nave_sprite_normal
    
    lw $t1, invul_frames
    andi $t1, $t1, 2
    bnez $t1, dibujar_nave_sprite_fin

dibujar_nave_sprite_normal:
    # Obtener ángulo actual (0-7)
    lw $s0, nave_angulo
    
    # Calcular dirección del sprite (25 bytes por sprite)
    li $t0, 25
    mult $s0, $t0
    mflo $t1
    la $s1, nave_sprites
    addu $s1, $s1, $t1
    
    # Obtener posición central de la nave
    lw $t2, nave_x
    lw $t3, nave_y
    
    # Ajustar para centrar el sprite 5x5
    addiu $t2, $t2, -2  # x - 2
    addiu $t3, $t3, -2  # y - 2
    
    # Dibujar sprite 5x5
    li $s2, 0        # fila (0-4)
    
dibujar_nave_fila:
    li $s3, 0        # columna (0-4)
    
dibujar_nave_columna:
    # Calcular posición en el array del sprite: fila * 5 + columna
    li $t4, 5
    mult $s2, $t4
    mflo $t5
    addu $t5, $t5, $s3
    addu $t6, $s1, $t5
    
    # Leer valor del pixel (0-5)
    lb $t7, 0($t6)
    
    # Si no es 0, dibujar el pixel
    beqz $t7, nave_sprite_siguiente
    
    # Calcular posición absoluta en pantalla
    move $a0, $t2    # x base
    addu $a0, $a0, $s3  # + columna
    move $a1, $t3    # y base  
    addu $a1, $a1, $s2  # + fila
    
    # Obtener color real
    move $a2, $t7    # código de color (1-5)
    jal obtener_color_nave_sprite
    move $a2, $v0    # color real
    
    jal pixel_back

nave_sprite_siguiente:
    addiu $s3, $s3, 1
    li $t0, 5
    blt $s3, $t0, dibujar_nave_columna
    
    addiu $s2, $s2, 1
    li $t0, 5
    blt $s2, $t0, dibujar_nave_fila

dibujar_nave_sprite_fin:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# Función para obtener color de la paleta de la nave
obtener_color_nave_sprite:
    # $a2: código de color (1-5)
    beq $a2, 1, color_nave_1
    beq $a2, 2, color_nave_2
    beq $a2, 3, color_nave_3
    beq $a2, 4, color_nave_4
    beq $a2, 5, color_nave_5
    j color_nave_default
    
color_nave_1:
    lw $v0, nave_color_1
    jr $ra
color_nave_2:
    lw $v0, nave_color_2
    jr $ra
color_nave_3:
    lw $v0, nave_color_3
    jr $ra
color_nave_4:
    lw $v0, nave_color_4
    jr $ra
color_nave_5:
    lw $v0, nave_color_5
    jr $ra
color_nave_default:
    lw $v0, nave_color_0
    jr $ra
teclas:
    lui $t0, 0xffff
    lw $t1, 0($t0)
    andi $t1, $t1, 1
    beqz $t1, teclas_fin
    
    lw $t2, 4($t0)
    
    li $t3, 119      # 'w' - avanzar
    beq $t2, $t3, t_avanzar
    li $t3, 100       # 'a' - rotar izquierda
    beq $t2, $t3, t_rotar_izq
    li $t3, 97      # 'd' - rotar derecha
    beq $t2, $t3, t_rotar_der
    li $t3, 106      # 'j' - disparar
    beq $t2, $t3, t_disparar
    j teclas_fin

t_avanzar:
    lw $t0, nave_angulo
    lw $t1, nave_x
    lw $t2, nave_y
    lw $t3, nave_velocidad
    
    beq $t0, 0, avanzar_derecha
    beq $t0, 1, avanzar_diag_sup_der
    beq $t0, 2, avanzar_arriba
    beq $t0, 3, avanzar_diag_sup_izq
    beq $t0, 4, avanzar_izquierda
    beq $t0, 5, avanzar_diag_inf_izq
    beq $t0, 6, avanzar_abajo
    j avanzar_diag_inf_der

avanzar_derecha:
    add $t1, $t1, $t3
    j avanzar_fin

avanzar_diag_sup_der:
    add $t1, $t1, $t3
    sub $t2, $t2, $t3
    j avanzar_fin

avanzar_arriba:
    sub $t2, $t2, $t3
    j avanzar_fin

avanzar_diag_sup_izq:
    sub $t1, $t1, $t3
    sub $t2, $t2, $t3
    j avanzar_fin

avanzar_izquierda:
    sub $t1, $t1, $t3
    j avanzar_fin

avanzar_diag_inf_izq:
    sub $t1, $t1, $t3
    add $t2, $t2, $t3
    j avanzar_fin

avanzar_abajo:
    add $t2, $t2, $t3
    j avanzar_fin

avanzar_diag_inf_der:
    add $t1, $t1, $t3
    add $t2, $t2, $t3

avanzar_fin:
    bgez $t1, check_x_max
    li $t1, 0
check_x_max:
    li $t4, 61
    ble $t1, $t4, check_y_min
    li $t1, 61
check_y_min:
    bgez $t2, check_y_max
    li $t2, 0
check_y_max:
    li $t4, 61
    ble $t2, $t4, guardar_pos
    li $t2, 61

guardar_pos:
    sw $t1, nave_x
    sw $t2, nave_y
    j teclas_fin

t_rotar_izq:
    lw $t0, nave_angulo
    addiu $t0, $t0, 7      # Rotación antihoraria CORREGIDA
    li $t1, 8
    blt $t0, $t1, guardar_angulo
    addiu $t0, $t0, -8
    j guardar_angulo

t_rotar_der:
    lw $t0, nave_angulo
    addiu $t0, $t0, 1      # Rotación horaria CORREGIDA
    li $t1, 8
    blt $t0, $t1, guardar_angulo
    li $t0, 0

guardar_angulo:
    sw $t0, nave_angulo

teclas_fin:
    jr $ra

# ==========================================
# DOUBLE BUFFERING FUNCTIONS
# ==========================================
limpiar_back_buffer:
    lw $t0, display_back
    lw $t1, negro
    li $t2, 4096
limpiar_back_loop:
    sw $t1, 0($t0)
    addiu $t0, $t0, 4
    addiu $t2, $t2, -1
    bnez $t2, limpiar_back_loop
    jr $ra

swap_buffers:
    lw $t0, display
    lw $t1, display_back
    li $t2, 4096
swap_loop:
    lw $t3, 0($t1)
    sw $t3, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, 4
    addiu $t2, $t2, -1
    bnez $t2, swap_loop
    jr $ra

# ==========================================
# PIXEL PARA BACK BUFFER
# ==========================================
pixel_back:
    bltz $a0, pixel_back_fin
    li $t9, 64
    bge $a0, $t9, pixel_back_fin
    bltz $a1, pixel_back_fin
    bge $a1, $t9, pixel_back_fin
    
    sll $t0, $a1, 6
    addu $t0, $t0, $a0
    sll $t0, $t0, 2
    
    lw $t1, display_back
    addu $t1, $t1, $t0
    sw $a2, 0($t1)

pixel_back_fin:
    jr $ra


#===========================================
#===========================================
t_disparar:
    lw $t0, num_balas
    lw $t1, max_balas
    bge $t0, $t1, teclas_fin  # No disparar si hay muchas balas
    
    # Crear nueva bala
    la $t2, balas
    mul $t3, $t0, 20  # 20 bytes por bala
    addu $t4, $t2, $t3
    
    # Obtener posición y dirección de la nave
    lw $t5, nave_x
    lw $t6, nave_y
    lw $t7, nave_angulo
    
    # Posicionar bala en el centro de la nave
    sw $t5, 0($t4)    # x
    sw $t6, 4($t4)    # y
    
    # Calcular dirección según ángulo
    li $t8, 2  # velocidad de la bala
    
    beq $t7, 0, disparar_derecha
    beq $t7, 1, disparar_diag_sup_der
    beq $t7, 2, disparar_arriba
    beq $t7, 3, disparar_diag_sup_izq
    beq $t7, 4, disparar_izquierda
    beq $t7, 5, disparar_diag_inf_izq
    beq $t7, 6, disparar_abajo
    j disparar_diag_inf_der

disparar_derecha:
    sw $t8, 8($t4)    # dx = 2
    sw $zero, 12($t4) # dy = 0
    j disparar_fin

disparar_diag_sup_der:
    sw $t8, 8($t4)    # dx = 2
    li $t9, -2
    sw $t9, 12($t4)   # dy = -2
    j disparar_fin

disparar_arriba:
    sw $zero, 8($t4)  # dx = 0
    li $t9, -2
    sw $t9, 12($t4)   # dy = -2
    j disparar_fin

disparar_diag_sup_izq:
    li $t9, -2
    sw $t9, 8($t4)    # dx = -2
    sw $t9, 12($t4)   # dy = -2
    j disparar_fin

disparar_izquierda:
    li $t9, -2
    sw $t9, 8($t4)    # dx = -2
    sw $zero, 12($t4) # dy = 0
    j disparar_fin

disparar_diag_inf_izq:
    li $t9, -2
    sw $t9, 8($t4)    # dx = -2
    sw $t8, 12($t4)   # dy = 2
    j disparar_fin

disparar_abajo:
    sw $zero, 8($t4)  # dx = 0
    sw $t8, 12($t4)   # dy = 2
    j disparar_fin

disparar_diag_inf_der:
    sw $t8, 8($t4)    # dx = 2
    sw $t8, 12($t4)   # dy = 2

disparar_fin:
    li $t9, 1
    sw $t9, 16($t4)   # activa = 1
    
    # Incrementar contador de balas
    addiu $t0, $t0, 1
    sw $t0, num_balas
    
    j teclas_fin
# ==========================================
# DIBUJAR METEORITO GRANDE (8x8) CON SPRITE
# ==========================================
dibujar_meteorito_grande_back:
    # $a0 = x, $a1 = y
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)  # direcci�n del sprite
    sw $s1, 8($sp)   # coordenada Y del sprite
    sw $s2, 4($sp)   # coordenada X del sprite
    sw $s3, 0($sp)   # valor del pixel
    
    move $s0, $a0  # Guardar posici�n base x
    move $s1, $a1  # Guardar posici�n base y
    
    la $t0, asteroide_grande_sprite
    li $t1, 0      # fila
    
dibujar_grande_fila:
    li $t2, 0      # columna
    
dibujar_grande_columna:
    # Calcular posici�n en el array: fila * 8 + columna
    sll $t3, $t1, 3    # fila * 8
    addu $t3, $t3, $t2  # + columna
    addu $t4, $t0, $t3
    
    lb $t5, 0($t4)     # leer valor del pixel
    
    # Si es 0, no dibujar
    beqz $t5, grande_siguiente_pixel
    
    # Calcular posici�n absoluta en pantalla
    move $a0, $s0
    addu $a0, $a0, $t2  # x + columna
    move $a1, $s1
    addu $a1, $a1, $t1  # y + fila
    
    move $a2, $t5
    addiu $sp, $sp, -12
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    jal obtener_color_asteroide
    move $a2, $v0
    jal pixel_back
    lw $t2, 0($sp)
    lw $t1, 4($sp)
    lw $t0, 8($sp)
    addiu $sp, $sp, 12
    
grande_siguiente_pixel:
    addiu $t2, $t2, 1
    li $t6, 8
    blt $t2, $t6, dibujar_grande_columna
    
    addiu $t1, $t1, 1
    li $t6, 8
    blt $t1, $t6, dibujar_grande_fila
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# ==========================================
# DIBUJAR METEORITO MEDIANO (5x5) CON SPRITE
# ==========================================
dibujar_meteorito_mediano_back:
    # $a0 = x, $a1 = y
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    la $t0, asteroide_mediano_sprite
    li $t1, 0
    
dibujar_mediano_fila:
    li $t2, 0
    
dibujar_mediano_columna:
    # Calcular posici�n: fila * 5 + columna
    li $t3, 5
    mult $t1, $t3
    mflo $t3
    addu $t3, $t3, $t2
    addu $t4, $t0, $t3
    
    lb $t5, 0($t4)
    
    beqz $t5, mediano_siguiente_pixel
    
    move $a0, $s0
    addu $a0, $a0, $t2
    move $a1, $s1
    addu $a1, $a1, $t1
    
    move $a2, $t5
    addiu $sp, $sp, -12
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    jal obtener_color_asteroide
    move $a2, $v0
    jal pixel_back
    lw $t2, 0($sp)
    lw $t1, 4($sp)
    lw $t0, 8($sp)
    addiu $sp, $sp, 12
    
mediano_siguiente_pixel:
    addiu $t2, $t2, 1
    li $t6, 5
    blt $t2, $t6, dibujar_mediano_columna
    
    addiu $t1, $t1, 1
    li $t6, 5
    blt $t1, $t6, dibujar_mediano_fila
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra
    
    # ==========================================
# DIBUJAR METEORITO PEQUE�O (3x3) CON SPRITE
# ==========================================
dibujar_meteorito_pequeno_back:
    # $a0 = x, $a1 = y
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0
    move $s1, $a1
    
    la $t0, asteroide_pequeno_sprite
    li $t1, 0
    
dibujar_pequeno_fila:
    li $t2, 0
    
dibujar_pequeno_columna:
    # Calcular posici�n: fila * 3 + columna
    li $t3, 3
    mult $t1, $t3
    mflo $t3
    addu $t3, $t3, $t2
    addu $t4, $t0, $t3
    
    lb $t5, 0($t4)
    
    beqz $t5, pequeno_siguiente_pixel
    
    move $a0, $s0
    addu $a0, $a0, $t2
    move $a1, $s1
    addu $a1, $a1, $t1
    
    move $a2, $t5
    addiu $sp, $sp, -12
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)
    jal obtener_color_asteroide
    move $a2, $v0
    jal pixel_back
    lw $t2, 0($sp)
    lw $t1, 4($sp)
    lw $t0, 8($sp)
    addiu $sp, $sp, 12
    
pequeno_siguiente_pixel:
    addiu $t2, $t2, 1
    li $t6, 3
    blt $t2, $t6, dibujar_pequeno_columna
    
    addiu $t1, $t1, 1
    li $t6, 3
    blt $t1, $t6, dibujar_pequeno_fila
    
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

# ==========================================
# FUNCIONES DE DIBUJO
# ==========================================
dibujar_calavera_back:
    jal limpiar_back_buffer
    lw $a2, blanco
    
    # Ojos de la calavera
    li $a0, 29
    li $a1, 28
    jal pixel_back
    li $a0, 34
    jal pixel_back
    
    # Nariz
    li $a0, 31
    li $a1, 30
    jal pixel_back
    li $a0, 32
    jal pixel_back
    
    # Boca
    li $a0, 28
    li $a1, 32
    jal pixel_back
    li $a0, 29
    li $a1, 33
    jal pixel_back
    li $a0, 30
    li $a1, 34
    jal pixel_back
    li $a0, 31
    li $a1, 34
    jal pixel_back
    li $a0, 32
    li $a1, 34
    jal pixel_back
    li $a0, 33
    li $a1, 33
    jal pixel_back
    li $a0, 34
    li $a1, 32
    jal pixel_back
    
    jal swap_buffers
    jr $ra

dibujar_vidas_back:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t0, vidas
    lw $a2, verde
    
    beq $t0, 3, dibujar_tres_vidas_back
    beq $t0, 2, dibujar_dos_vidas_back  
    beq $t0, 1, dibujar_una_vida_back
    j dibujar_vidas_back_fin

dibujar_tres_vidas_back:
    li $a0, 2
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back
    
    li $a0, 5
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back
    
    li $a0, 8
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back
    j dibujar_vidas_back_fin

dibujar_dos_vidas_back:
    li $a0, 2
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back
    
    li $a0, 5
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back
    j dibujar_vidas_back_fin

dibujar_una_vida_back:
    li $a0, 2
    li $a1, 2
    jal pixel_back
    addiu $a0, $a0, 1
    jal pixel_back

dibujar_vidas_back_fin:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

dibujar_asteroides_back:
    lw $t0, num_ast
    beqz $t0, dibujar_ast_back_fin
    
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    li $s0, 0
    la $t7, asteroides

dibujar_ast_back_loop:
    lw $t0, num_ast
    bge $s0, $t0, dibujar_ast_back_done
    
    # Cada asteroide usa 24 bytes: x, y, dx, dy, tipo, velocidad
    mul $t2, $s0, 24
    addu $t3, $t7, $t2
    
    lw $a0, 0($t3)    # x
    lw $a1, 4($t3)    # y
    lw $t4, 16($t3)   # tipo (0=pequeño, 1=grande, 2=mediano)
    
    beqz $t4, dibujar_ast_pequeno_back
    li $t5, 1
    beq $t4, $t5, dibujar_ast_grande_back
    
    # Dibujar asteroide mediano (5x5) - CORREGIDO
    jal dibujar_meteorito_mediano_back
    j siguiente_ast_back
    
dibujar_ast_grande_back:
    # Dibujar asteroide grande (8x8) - CORREGIDO
    jal dibujar_meteorito_grande_back
    j siguiente_ast_back
    
dibujar_ast_pequeno_back:
    # Dibujar asteroide pequeño (3x3) - CORREGIDO
    jal dibujar_meteorito_pequeno_back

siguiente_ast_back:
    addiu $s0, $s0, 1
    j dibujar_ast_back_loop
    
dibujar_ast_back_done:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    
dibujar_ast_back_fin:
    jr $ra

# ==========================================
# FUNCIONES DE COLISIONES ACTUALIZADAS CON NUEVOS TAMA�OS
# ==========================================
verificar_colisiones:
    lw $t0, invulnerable
    bnez $t0, colisiones_fin
    
    lw $t0, num_ast
    beqz $t0, colisiones_fin
    
    lw $t1, nave_x
    lw $t2, nave_y
    
    # La nave es 5x5 (centrada en la posici�n)
    addiu $s4, $t1, 2    # x_max (centro + 2)
    addiu $s5, $t2, 2    # y_max (centro + 2)
    addiu $s6, $t1, -2   # x_min (centro - 2)  
    addiu $s7, $t2, -2   # y_min (centro - 2)
    
    li $t3, 0
    la $t4, asteroides

colisiones_loop:
    bge $t3, $t0, colisiones_fin
    
    mul $t5, $t3, 24
    addu $t6, $t4, $t5
    
    lw $t7, 0($t6)    # x del asteroide
    lw $t8, 4($t6)    # y del asteroide
    lw $s0, 16($t6)   # tipo del asteroide
    
    # Verificar colisi�n seg�n tipo de asteroide
    beqz $s0, colision_pequena
    li $t9, 1
    beq $s0, $t9, colision_grande
    j colision_mediana

colision_pequena:
    # Asteroide peque�o (3x3)
    addiu $t9, $t7, 2    # x_max del asteroide (x + 2)
    addiu $k0, $t8, 2    # y_max del asteroide (y + 2)
    
    bgt $s6, $t9, siguiente_colision  # x_min_nave > x_max_ast
    bgt $t7, $s4, siguiente_colision  # x_min_ast > x_max_nave
    bgt $s7, $k0, siguiente_colision  # y_min_nave > y_max_ast
    bgt $t8, $s5, siguiente_colision  # y_min_ast > y_max_nave
    j colision_detectada

colision_mediana:
    # Asteroide mediano (5x5)
    addiu $t9, $t7, 4    # x_max del asteroide (x + 4)
    addiu $k0, $t8, 4    # y_max del asteroide (y + 4)
    
    bgt $s6, $t9, siguiente_colision
    bgt $t7, $s4, siguiente_colision
    bgt $s7, $k0, siguiente_colision
    bgt $t8, $s5, siguiente_colision
    j colision_detectada

colision_grande:
    # Asteroide grande (8x8)
    addiu $t9, $t7, 7    # x_max del asteroide (x + 7)
    addiu $k0, $t8, 7    # y_max del asteroide (y + 7)
    
    bgt $s6, $t9, siguiente_colision
    bgt $t7, $s4, siguiente_colision
    bgt $s7, $k0, siguiente_colision
    bgt $t8, $s5, siguiente_colision
    
colision_detectada:
    lw $s0, vidas
    addiu $s0, $s0, -1
    sw $s0, vidas
    li $s1, 100
    sw $s1, 4($t6)
    li $s2, 1
    sw $s2, invulnerable
    sw $zero, invul_frames
    bgtz $s0, colisiones_fin
    li $s2, 1
    sw $s2, game_over
    j colisiones_fin

siguiente_colision:
    addiu $t3, $t3, 1
    j colisiones_loop

colisiones_fin:
    jr $ra

# ==========================================
# FUNCIONES DE MOVIMIENTO
# ==========================================
mover_balas:
    lw $t0, num_balas
    beqz $t0, mover_balas_fin
    
    li $t1, 0           # índice actual
    la $t7, balas

mover_balas_loop:
    bge $t1, $t0, mover_balas_fin
    
    mul $t2, $t1, 20
    addu $t3, $t7, $t2
    
    # Verificar si la bala está activa
    lw $t4, 16($t3)
    beqz $t4, bala_ya_desactivada
    
    # Mover bala
    lw $t5, 0($t3)    # x
    lw $t6, 4($t3)    # y
    lw $t8, 8($t3)    # dx
    lw $t9, 12($t3)   # dy
    
    addu $t5, $t5, $t8
    addu $t6, $t6, $t9
    
    # Verificar si la bala salió de la pantalla
    bltz $t5, desactivar_bala
    bltz $t6, desactivar_bala
    li $s0, 64
    bge $t5, $s0, desactivar_bala
    bge $t6, $s0, desactivar_bala
    
    # Actualizar posición
    sw $t5, 0($t3)
    sw $t6, 4($t3)
    j siguiente_bala

bala_ya_desactivada:
    # Si la bala ya está desactivada, reorganizar el array
    lw $s1, num_balas
    addiu $s1, $s1, -1
    sw $s1, num_balas
    
    beq $t1, $s1, mover_balas_fin  # Si es la última, terminar
    
    # Copiar última bala a la posición actual
    mul $s2, $s1, 20
    addu $s3, $t7, $s2
    
    lw $s4, 0($s3)    # x
    lw $s5, 4($s3)    # y
    lw $s6, 8($s3)    # dx
    lw $s7, 12($s3)   # dy
    lw $k0, 16($s3)   # activa (usamos $k0 en lugar de $s8)
    
    sw $s4, 0($t3)
    sw $s5, 4($t3)
    sw $s6, 8($t3)
    sw $s7, 12($t3)
    sw $k0, 16($t3)
    
    # No incrementar índice porque ahora tenemos una nueva bala en esta posición
    j mover_balas_loop

desactivar_bala:
    # Desactivar esta bala
    sw $zero, 16($t3)
    
    # Reorganizar array inmediatamente
    lw $s1, num_balas
    addiu $s1, $s1, -1
    sw $s1, num_balas
    
    beq $t1, $s1, mover_balas_fin  # Si es la última, terminar
    
    # Copiar última bala a la posición actual
    mul $s2, $s1, 20
    addu $s3, $t7, $s2
    
    lw $s4, 0($s3)    # x
    lw $s5, 4($s3)    # y
    lw $s6, 8($s3)    # dx
    lw $s7, 12($s3)   # dy
    lw $k0, 16($s3)   # activa (usamos $k0 en lugar de $s8)
    
    sw $s4, 0($t3)
    sw $s5, 4($t3)
    sw $s6, 8($t3)
    sw $s7, 12($t3)
    sw $k0, 16($t3)
    
    # No incrementar índice porque ahora tenemos una nueva bala en esta posición
    j mover_balas_loop

siguiente_bala:
    addiu $t1, $t1, 1
    j mover_balas_loop

mover_balas_fin:
    jr $ra

# Función para dibujar las balas
dibujar_balas_back:
    lw $t0, num_balas
    beqz $t0, dibujar_balas_fin
    
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)
    
    li $s0, 0
    la $t7, balas

dibujar_balas_loop:
    lw $t0, num_balas
    bge $s0, $t0, dibujar_balas_done
    
    mul $t2, $s0, 20
    addu $t3, $t7, $t2
    
    # Verificar si la bala está activa - CORRECCIÓN AQU�?
    lw $t4, 16($t3)
    beqz $t4, siguiente_bala_dibujo  # Usar $t4 en lugar de $s0
    
    lw $a0, 0($t3)    # x
    lw $a1, 4($t3)    # y
    lw $a2, blanco    # color blanco para las balas
    
    jal pixel_back

siguiente_bala_dibujo:
    addiu $s0, $s0, 1
    j dibujar_balas_loop

dibujar_balas_done:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12

dibujar_balas_fin:
    jr $ra


colision_bala_detectada:
    sw $zero, 16($s3)
    li $k0, 100
    sw $k0, 4($t9)
    j siguiente_bala_colision

    
actualizar_invulnerabilidad:
    lw $t0, invulnerable
    beqz $t0, invul_fin
    lw $t1, invul_frames
    addiu $t1, $t1, 1
    sw $t1, invul_frames
    li $t2, 30
    blt $t1, $t2, invul_fin
    sw $zero, invulnerable
    sw $zero, invul_frames
invul_fin:
    jr $ra

rand:
    lw $t0, seed
    li $t1, 1103515245
    mult $t0, $t1
    mflo $t0
    addiu $t0, $t0, 12345
    sw $t0, seed
    move $v0, $t0
    jr $ra

crear_asteroide:
    lw $t0, frames
    addiu $t0, $t0, 1
    sw $t0, frames
    li $t1, 15
    blt $t0, $t1, crear_fin
    sw $zero, frames
    lw $t0, num_ast
    li $t1, 15
    bge $t0, $t1, crear_fin
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    jal rand
    move $s1, $v0
    andi $t0, $s1, 0x3
    li $t1, 3
    beq $t0, $t1, crear_fin_pop
    srl $s2, $s1, 8
    andi $s2, $s2, 0xFF
    li $t9, 86
    blt $s2, $t9, asteroide_pequeno
    li $t9, 171
    blt $s2, $t9, asteroide_mediano
    li $s0, 1
    j decidir_velocidad
asteroide_pequeno:
    li $s0, 0
    j decidir_velocidad
asteroide_mediano:
    li $s0, 2
decidir_velocidad:
    srl $s3, $s1, 4
    andi $s3, $s3, 0x3
    addiu $s3, $s3, 1
    li $t9, 4
    blt $s3, $t9, decidir_direccion
    li $s3, 3
decidir_direccion:
    srl $t2, $s1, 16
    andi $t2, $t2, 0x3
    beqz $t2, desde_arriba
    li $t3, 1
    beq $t2, $t3, desde_izquierda
    li $t3, 2
    beq $t2, $t3, desde_derecha
    j desde_diagonal
desde_arriba:
    andi $t4, $s1, 63
    beqz $s0, desde_arriba_pequeno
    li $t5, 2
    beq $s0, $t5, desde_arriba_mediano
    blt $t4, 2, ajustar_arriba_grande_min
    bgt $t4, 59, ajustar_arriba_grande_max
    j desde_arriba_continuar
desde_arriba_pequeno:
    # Asteroide peque�o es 3x3, l�mites 0-61
    blt $t4, 0, ajustar_arriba_pequeno_min
    bgt $t4, 61, ajustar_arriba_pequeno_max
    j desde_arriba_continuar

ajustar_arriba_pequeno_min:
    li $t4, 0
    j desde_arriba_continuar

ajustar_arriba_pequeno_max:
    li $t4, 61
    j desde_arriba_continuar

desde_arriba_mediano:
    # Asteroide mediano es 5x5, l�mites 0-59
    blt $t4, 0, ajustar_arriba_mediano_min
    bgt $t4, 59, ajustar_arriba_mediano_max
    j desde_arriba_continuar
ajustar_arriba_mediano_min:
	li $t4, 0
   	j desde_arriba_continuar
ajustar_arriba_mediano_max:
	li $t4, 59
    	j desde_arriba_continuar
desde_arriba_grande:
    # Asteroide grande es 8x8, l�mites 0-56
    blt $t4, 0, ajustar_arriba_grande_min
    bgt $t4, 56, ajustar_arriba_grande_max
    j desde_arriba_continuar

ajustar_arriba_grande_min:
    li $t4, 0
    j desde_arriba_continuar

ajustar_arriba_grande_max:
    li $t4, 56
    j desde_arriba_continuar
    
desde_arriba_continuar:
    li $t5, 0
    li $t6, 0
    li $t7, 1
    j aplicar_velocidad
desde_izquierda:
    andi $t5, $s1, 63
    beqz $s0, desde_izquierda_pequeno
    li $t8, 2
    beq $s0, $t8, desde_izquierda_mediano
    blt $t5, 2, ajustar_izquierda_grande_min
    bgt $t5, 59, ajustar_izquierda_grande_max
    j desde_izquierda_continuar
desde_izquierda_mediano:
    blt $t5, 1, ajustar_izquierda_mediano_min
    bgt $t5, 61, ajustar_izquierda_mediano_max
    j desde_izquierda_continuar
desde_izquierda_pequeno:
    j desde_izquierda_continuar
ajustar_izquierda_grande_min:
    li $t5, 2
    j desde_izquierda_continuar
ajustar_izquierda_grande_max:
    li $t5, 59
    j desde_izquierda_continuar
ajustar_izquierda_mediano_min:
    li $t5, 1
    j desde_izquierda_continuar
ajustar_izquierda_mediano_max:
    li $t5, 61
desde_izquierda_continuar:
    li $t4, 0
    li $t6, 1
    li $t7, 0
    j aplicar_velocidad
desde_derecha:
    andi $t5, $s1, 63
    beqz $s0, desde_derecha_pequeno
    li $t8, 2
    beq $s0, $t8, desde_derecha_mediano
    blt $t5, 2, ajustar_derecha_grande_min
    bgt $t5, 59, ajustar_derecha_grande_max
    j desde_derecha_continuar
desde_derecha_mediano:
    blt $t5, 1, ajustar_derecha_mediano_min
    bgt $t5, 61, ajustar_derecha_mediano_max
    j desde_derecha_continuar
desde_derecha_pequeno:
    j desde_derecha_continuar
ajustar_derecha_grande_min:
    li $t5, 2
    j desde_derecha_continuar
ajustar_derecha_grande_max:
    li $t5, 59
    j desde_derecha_continuar
ajustar_derecha_mediano_min:
    li $t5, 1
    j desde_derecha_continuar
ajustar_derecha_mediano_max:
    li $t5, 61
desde_derecha_continuar:
    li $t4, 63
    li $t6, -1
    li $t7, 0
    j aplicar_velocidad
desde_diagonal:
    srl $t8, $s1, 24
    andi $t8, $t8, 0x1
    beqz $t8, diagonal_abajo_derecha
    li $t4, 63
    andi $t5, $s1, 63
    li $t6, -1
    li $t7, 1
    j diagonal_ajustar
diagonal_abajo_derecha:
    li $t4, 0
    andi $t5, $s1, 63
    li $t6, 1
    li $t7, 1
diagonal_ajustar:
    beqz $s0, aplicar_velocidad
    li $t8, 2
    beq $s0, $t8, diagonal_ajustar_mediano
    blt $t5, 2, ajustar_diagonal_grande_min
    bgt $t5, 59, ajustar_diagonal_grande_max
    j aplicar_velocidad
diagonal_ajustar_mediano:
    blt $t5, 1, ajustar_diagonal_mediano_min
    bgt $t5, 61, ajustar_diagonal_mediano_max
    j aplicar_velocidad
ajustar_diagonal_grande_min:
    li $t5, 2
    j aplicar_velocidad
ajustar_diagonal_grande_max:
    li $t5, 59
    j aplicar_velocidad
ajustar_diagonal_mediano_min:
    li $t5, 1
    j aplicar_velocidad
ajustar_diagonal_mediano_max:
    li $t5, 61
aplicar_velocidad:
    mult $t6, $s3
    mflo $t6
    mult $t7, $s3
    mflo $t7
guardar_ast:
    lw $t9, num_ast
    mul $t2, $t9, 24
    la $t3, asteroides
    addu $t3, $t3, $t2
    sw $t4, 0($t3)
    sw $t5, 4($t3)
    sw $t6, 8($t3)
    sw $t7, 12($t3)
    sw $s0, 16($t3)
    sw $s3, 20($t3)
    addiu $t9, $t9, 1
    sw $t9, num_ast
crear_fin_pop:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
crear_fin:
    jr $ra

mover_asteroides:
    lw $t0, num_ast
    beqz $t0, mover_fin
    li $t1, 0
    la $t7, asteroides
mover_loop:
    bge $t1, $t0, mover_fin
    mul $t2, $t1, 24
    addu $t3, $t7, $t2
    lw $t4, 0($t3)
    lw $t5, 4($t3)
    lw $t6, 8($t3)
    lw $t8, 12($t3)
    addu $t4, $t4, $t6
    addu $t5, $t5, $t8
    li $t9, 64
    bge $t5, $t9, borrar_ast
    bltz $t5, borrar_ast
    bge $t4, $t9, borrar_ast
    bltz $t4, borrar_ast
    sw $t4, 0($t3)
    sw $t5, 4($t3)
    addiu $t1, $t1, 1
    j mover_loop
borrar_ast:
    lw $t0, num_ast
    addiu $t0, $t0, -1
    sw $t0, num_ast
    beq $t1, $t0, mover_fin
    mul $t9, $t0, 24
    addu $s0, $t7, $t9
    lw $s1, 0($s0)
    lw $s2, 4($s0)
    lw $s3, 8($s0)
    lw $s4, 12($s0)
    lw $s5, 16($s0)
    lw $s6, 20($s0)
    sw $s1, 0($t3)
    sw $s2, 4($t3)
    sw $s3, 8($t3)
    sw $s4, 12($t3)
    sw $s5, 16($t3)
    sw $s6, 20($t3)
    j mover_loop
mover_fin:
    jr $ra

esperar:
    li $t0, 20000
esperar_loop:
    addiu $t0, $t0, -1
    bnez $t0, esperar_loop
    jr $ra
    
    
# Función para verificar colisiones entre balas y asteroides (ACTUALIZADA CON DIVISIÓN)
verificar_colisiones_balas:
    lw $t0, num_balas
    beqz $t0, colisiones_balas_fin
    lw $t1, num_ast
    beqz $t1, colisiones_balas_fin
    
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    la $s0, balas
    li $s1, 0

colisiones_balas_loop:
    lw $t0, num_balas
    bge $s1, $t0, colisiones_balas_done
    
    mul $s2, $s1, 20
    addu $s3, $s0, $s2
    
    lw $t2, 16($s3)
    beqz $t2, siguiente_bala_colision_avanzar
    
    lw $t3, 0($s3)    # x_bala
    lw $t4, 4($s3)    # y_bala
    
    li $t5, 0
    la $t6, asteroides
    lw $t7, num_ast

colisiones_ast_loop:
    bge $t5, $t7, siguiente_bala_colision
    
    mul $t8, $t5, 24
    addu $t9, $t6, $t8
    
    lw $s4, 0($t9)    # x_ast
    lw $s5, 4($t9)    # y_ast
    lw $s6, 16($t9)   # tipo_ast
    
    # Verificar colisión según tipo
    beqz $s6, colision_bala_pequena
    li $s7, 1
    beq $s6, $s7, colision_bala_grande
    j colision_bala_mediana

colision_bala_pequena:
    # Asteroide pequeño (3x3)
    addiu $k0, $s4, 2
    addiu $k1, $s5, 2
    blt $t3, $s4, siguiente_ast_colision
    bgt $t3, $k0, siguiente_ast_colision
    blt $t4, $s5, siguiente_ast_colision
    bgt $t4, $k1, siguiente_ast_colision
    j colision_bala_detectada_sin_division

colision_bala_mediana:
    # Asteroide mediano (5x5)
    addiu $k0, $s4, 4
    addiu $k1, $s5, 4
    blt $t3, $s4, siguiente_ast_colision
    bgt $t3, $k0, siguiente_ast_colision
    blt $t4, $s5, siguiente_ast_colision
    bgt $t4, $k1, siguiente_ast_colision
    j colision_bala_detectada_dividir_mediano

colision_bala_grande:
    # Asteroide grande (8x8)
    addiu $k0, $s4, 7
    addiu $k1, $s5, 7
    blt $t3, $s4, siguiente_ast_colision
    bgt $t3, $k0, siguiente_ast_colision
    blt $t4, $s5, siguiente_ast_colision
    bgt $t4, $k1, siguiente_ast_colision
    j colision_bala_detectada_dividir_grande

colision_bala_detectada_sin_division:
    # Asteroide pequeño: solo desactivar bala y eliminar asteroide
    sw $zero, 16($s3)    # Desactivar bala
    li $k0, 100
    sw $k0, 4($t9)       # Mover asteroide fuera de pantalla
    j siguiente_bala_colision

colision_bala_detectada_dividir_grande:
    # Asteroide grande: dividir en 2 medianos
    sw $zero, 16($s3)    # Desactivar bala
    
    # Guardar valores importantes antes de llamar a la función
    addiu $sp, $sp, -32
    sw $t5, 28($sp)
    sw $t6, 24($sp)
    sw $t7, 20($sp)
    sw $t8, 16($sp)
    sw $t9, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    # Obtener velocidad del asteroide original
    lw $a2, 20($t9)      # velocidad original
    
    # Convertir asteroide actual en mediano (primera división)
    li $k0, 2            # tipo = mediano
    sw $k0, 16($t9)
    
    # Ajustar velocidad: primera mitad va hacia arriba-izquierda
    lw $k0, 8($t9)       # dx original
    lw $k1, 12($t9)      # dy original
    
    # Primera división: modificar dirección ligeramente a la izquierda
    addiu $k0, $k0, -1   # dx - 1
    addiu $k1, $k1, -1   # dy - 1
    sw $k0, 8($t9)
    sw $k1, 12($t9)
    
    # Crear segundo asteroide mediano
    move $a0, $s4        # x
    move $a1, $s5        # y
    addiu $a0, $a0, 2    # offset x
    addiu $a1, $a1, 2    # offset y
    
    # Segunda división: dirección hacia abajo-derecha
    lw $k0, 8($t9)       # dx original
    lw $k1, 12($t9)      # dy original
    addiu $a3, $k0, 2    # dx + 2
    addiu $t0, $k1, 2    # dy + 2
    
    jal crear_asteroide_division_mediano
    
    # Restaurar registros
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $t9, 12($sp)
    lw $t8, 16($sp)
    lw $t7, 20($sp)
    lw $t6, 24($sp)
    lw $t5, 28($sp)
    addiu $sp, $sp, 32
    
    j siguiente_bala_colision

colision_bala_detectada_dividir_mediano:
    # Asteroide mediano: dividir en 2 pequeños
    sw $zero, 16($s3)    # Desactivar bala
    
    # Guardar valores importantes
    addiu $sp, $sp, -32
    sw $t5, 28($sp)
    sw $t6, 24($sp)
    sw $t7, 20($sp)
    sw $t8, 16($sp)
    sw $t9, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)
    
    # Obtener velocidad del asteroide original
    lw $a2, 20($t9)      # velocidad original
    
    # Convertir asteroide actual en pequeño (primera división)
    li $k0, 0            # tipo = pequeño
    sw $k0, 16($t9)
    
    # Ajustar velocidad: primera mitad
    lw $k0, 8($t9)       # dx original
    lw $k1, 12($t9)      # dy original
    
    # Primera división: dirección ligeramente a la izquierda
    addiu $k0, $k0, -1   # dx - 1
    addiu $k1, $k1, -1   # dy - 1
    sw $k0, 8($t9)
    sw $k1, 12($t9)
    
    # Crear segundo asteroide pequeño
    move $a0, $s4        # x
    move $a1, $s5        # y
    addiu $a0, $a0, 1    # offset x
    addiu $a1, $a1, 1    # offset y
    
    # Segunda división: dirección hacia la derecha
    lw $k0, 8($t9)       # dx original
    lw $k1, 12($t9)      # dy original
    addiu $a3, $k0, 2    # dx + 2
    addiu $t0, $k1, 2    # dy + 2
    
    jal crear_asteroide_division_pequeno
    
    # Restaurar registros
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $t9, 12($sp)
    lw $t8, 16($sp)
    lw $t7, 20($sp)
    lw $t6, 24($sp)
    lw $t5, 28($sp)
    addiu $sp, $sp, 32
    
    j siguiente_bala_colision

siguiente_ast_colision:
    addiu $t5, $t5, 1
    j colisiones_ast_loop

siguiente_bala_colision:
    addiu $s1, $s1, 1
    j colisiones_balas_loop

siguiente_bala_colision_avanzar:
    addiu $s1, $s1, 1
    j colisiones_balas_loop

colisiones_balas_done:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20

colisiones_balas_fin:
    jr $ra

# ==========================================
# FUNCIONES AUXILIARES PARA DIVISIÓN DE ASTEROIDES
# ==========================================

# Crear asteroide mediano por división
# $a0 = x, $a1 = y, $a2 = velocidad, $a3 = dx, $t0 = dy
crear_asteroide_division_mediano:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar que no excedamos el límite de asteroides
    lw $t1, num_ast
    li $t2, 15
    bge $t1, $t2, crear_div_med_fin
    
    # Calcular posición en array
    mul $t3, $t1, 24
    la $t4, asteroides
    addu $t4, $t4, $t3
    
    # Guardar datos del nuevo asteroide mediano
    sw $a0, 0($t4)       # x
    sw $a1, 4($t4)       # y
    sw $a3, 8($t4)       # dx
    sw $t0, 12($t4)      # dy
    li $t5, 2            # tipo = mediano
    sw $t5, 16($t4)
    sw $a2, 20($t4)      # velocidad
    
    # Incrementar contador
    addiu $t1, $t1, 1
    sw $t1, num_ast
    
crear_div_med_fin:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

# Crear asteroide pequeño por división
# $a0 = x, $a1 = y, $a2 = velocidad, $a3 = dx, $t0 = dy
crear_asteroide_division_pequeno:
    addiu $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Verificar que no excedamos el límite de asteroides
    lw $t1, num_ast
    li $t2, 15
    bge $t1, $t2, crear_div_peq_fin
    
    # Calcular posición en array
    mul $t3, $t1, 24
    la $t4, asteroides
    addu $t4, $t4, $t3
    
    # Guardar datos del nuevo asteroide pequeño
    sw $a0, 0($t4)       # x
    sw $a1, 4($t4)       # y
    sw $a3, 8($t4)       # dx
    sw $t0, 12($t4)      # dy
    li $t5, 0            # tipo = pequeño
    sw $t5, 16($t4)
    sw $a2, 20($t4)      # velocidad
    
    # Incrementar contador
    addiu $t1, $t1, 1
    sw $t1, num_ast
    
crear_div_peq_fin:
    lw $ra, 0($sp)
    addiu $sp, $sp, 4
    jr $ra
