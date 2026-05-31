# Assembly (NASM x86-64)

Proyectos en **Assembly x86-64** con **NASM**, usando únicamente la biblioteca estándar del sistema (`syscall`) para E/S, sin dependencias externas.

---

## 📂 Módulos / Modules

| Módulo | Descripción |
|--------|-------------|
| [`core/foundations/`](core/foundations/) | **Fase 0 — Fundamentos**: `hello_world`, `hello_user`, `calculator`, `numbers` |

---

### ▶️ Comenzar / Getting Started

```bash
# Hello, World!
cd core/foundations/helloworld && make run

# Hello, User!
cd core/foundations/hellouser && make run

# Calculator Tests
cd core/foundations/unit_test/calculator && make run

# Numbers Tests
cd core/foundations/numbers && make run
```

---

### 📦 Requisitos / Requirements

| Herramienta | Instalación |
|-------------|-------------|
| [NASM](https://www.nasm.us/) | `sudo apt install nasm` (Linux) / `winget install nasm` (Windows) |
| `ld` (binutils) | `sudo apt install binutils` (Linux) |
| `make` | `sudo apt install make` (Linux) |

---

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
