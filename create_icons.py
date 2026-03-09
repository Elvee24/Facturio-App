#!/usr/bin/env python3
import os

# Código para criar um PNG simples do logo usando PIL/Pillow
try:
    from PIL import Image, ImageDraw
    
    def create_logo_icon(size):
        # Criar imagem com fundo azul
        img = Image.new('RGB', (size, size), color='#2196F3')
        draw = ImageDraw.Draw(img)
        
        # Desenhar retângulo branco (documento)
        margin = size * 0.3
        doc_width = size * 0.4
        doc_height = size * 0.5
        doc_x = (size - doc_width) / 2
        doc_y = (size - doc_height) / 2
        
        draw.rectangle(
            [doc_x, doc_y, doc_x + doc_width, doc_y + doc_height],
            fill='white',
            outline='white'
        )
        
        # Desenhar linhas no documento
        line_margin = doc_x + doc_width * 0.15
        line_width = doc_width * 0.7
        line_y = doc_y + doc_height * 0.2
        line_spacing = doc_height * 0.15
        
        for i in range(3):
            y = line_y + (i * line_spacing)
            draw.line(
                [line_margin, y, line_margin + line_width, y],
                fill='#2196F3',
                width=max(1, size // 50)
            )
        
        return img
    
    # Criar diretório se não existir
    os.makedirs('/media/huskydb/FicheirosA/IEFP/Facturio/assets/icons', exist_ok=True)
    
    # Gerar ícones em diferentes tamanhos
    sizes = [16, 32, 48, 64, 128, 256, 512]
    for size in sizes:
        img = create_logo_icon(size)
        img.save(f'/media/huskydb/FicheirosA/IEFP/Facturio/assets/icons/icon-{size}.png')
        print(f'Criado icon-{size}.png')
    
    # Criar favicon
    favicon = create_logo_icon(32)
    favicon.save('/media/huskydb/FicheirosA/IEFP/Facturio/web/favicon.png')
    print('Criado favicon.png')
    
    print('Todos os ícones foram criados com sucesso!')
    
except ImportError:
    print('PIL/Pillow não está instalado. Instalando...')
    os.system('pip3 install Pillow')
    print('Por favor, execute o script novamente.')
