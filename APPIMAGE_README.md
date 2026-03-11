# Facturio AppImage

AppImage executável para Linux. Funciona em qualquer distribuição Linux x86_64.

## Utilização

### Opção 1: Executar diretamente
```bash
./Facturio.AppImage
```

### Opção 2: Transferir e executar
```bash
# Descarregar ambos os ficheiros
# - Facturio.AppImage (script, 507 bytes)
# - Facturio.AppImage.tar.gz (dados, 23 MB)

# Tornar executável
chmod +x Facturio.AppImage

# Executar
./Facturio.AppImage
```

## Requisitos

- Linux x86_64 (qualquer distribuição moderna)
- Bash
- Bibliotecas GTK+ 3.0+ (normalmente já instaladas)

## Características

- ✅ Portável (sem instalação necessária)
- ✅ Auto-contido (dados embutidos/referenciados)
- ✅ Execução temporária (limpeza automática)
- ✅ Sem dependências de build

## Estrutura

- `Facturio.AppImage` - Script executável (507 bytes)
- `Facturio.AppImage.tar.gz` - Dados da aplicação (23 MB)
  - Executável compilado
  - Bibliotecas compartilhadas
  - Assets (ícones, fontes, etc.)

## Troubleshooting

### Erro: Permissão negada
```bash
chmod +x Facturio.AppImage
```

### Erro: Ficheiros não encontrados
- Verifique que ambos os ficheiros estão na mesma pasta
- Todos os ficheiros devem ser legíveis

### Problema de LD_LIBRARY_PATH
O AppImage configura o caminho automaticamente. Se houver conflitos com bibliotecas do sistema:
```bash
LD_LIBRARY_PATH="" ./Facturio.AppImage
```

---

Versão: 1.0.0
Data: 11 de março de 2026
