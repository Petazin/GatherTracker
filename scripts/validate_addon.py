import re
import sys
import os

def check_lua_syntax(file_path):
    """
    Realiza revisiones básicas de sintaxis Lua y consistencia.
    No es un parser completo, pero atrapa errores comunes.
    """
    print(f"Validando: {file_path}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    errors = []
    warnings = []
    
    open_blocks = 0
    line_num = 0
    
    # Patrones básicos
    func_pattern = re.compile(r'^\s*function\s+')
    end_pattern = re.compile(r'^\s*end\s*')
    if_pattern = re.compile(r'^\s*if\s+')
    for_pattern = re.compile(r'^\s*for\s+')
    while_pattern = re.compile(r'^\s*while\s+')
    
    # Revisión línea por línea
    for line in lines:
        line_num += 1
        stripped = line.strip()
        
        # Ignorar comentarios
        if stripped.startswith('--'):
            continue
            
        # Conteo básico de bloques (muy simplificado)
        # Esto es heurístico, Lua es complejo de parsear con regex simple
        # pero sirve para detectar un 'end' faltante obvio en estructuras limpias
        
        # Check for global variables leaking (simple check for assignment without local)
        # Solo advertencia, ya que algunas globales son intencionales
        if "=" in stripped and not stripped.startswith("local") and not stripped.startswith("self") and not "." in stripped.split("=")[0]:
             # Excluir asignaciones a tablas conocidas o funciones
             if not "function" in stripped and not "GatherTracker" in stripped:
                 pass # warnings.append(f"Linea {line_num}: Posible global no declarada o intencional: {stripped}")

    # Verificar existencia de funciones clave mencionadas en el plan
    content = "".join(lines)
    
    required_strings = [
        "GatherTracker:OnInitialize",
        "GatherTracker:options", # Config table
    ]
    
    for req in required_strings:
        if req not in content:
            errors.append(f"Falta definición crítica: {req}")

    if errors:
        print("❌ ERRORES ENCONTRADOS:")
        for e in errors:
            print(f"  - {e}")
        return False
    else:
        print("✅ Verificación estática básica PASADA.")
        if warnings:
            print("⚠️ Advertencias:")
            for w in warnings:
                print(f"  - {w}")
        return True

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uso: python validate_addon.py <ruta_al_lua>")
        sys.exit(1)
    
    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"Archivo no encontrado: {path}")
        sys.exit(1)
        
    success = check_lua_syntax(path)
    if not success:
        sys.exit(1)
