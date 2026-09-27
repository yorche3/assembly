# 🚀 Algoritmos Puros / Algorithms Pure — Assembly

Implementaciones de la [Fase 1 — Algoritmos Puros](https://yorche3.github.io/programming_languages/ROADMAP/#fase-1--algoritmos-puros--algorithms-pure-) en **Assembly x86-64** (NASM): ordenamientos elementales y estructuras de datos construidas desde cero.

Los módulos de esta fase no enlazan con libc: usan `syscall` para el sistema y declaran el indicador de fallo como constante del contrato en lugar de lanzar excepciones.

---

##  Módulos / Modules

| Módulo | Especificación | Enfoque | Tests | Estado |
|--------|---------------|---------|:-----:|:------:|
| [`naive_sort/`](naive_sort/) | [05_Naive_Sort](https://yorche3.github.io/programming_languages/core/algorithms/05_Naive_Sort/) | `Makefile` + `test/` | 24 | ✅ |
| [`data_structures_basics/`](data_structures_basics/) | [06_Data_Structures_Basics](https://yorche3.github.io/programming_languages/core/algorithms/06_Data_Structures_Basics/) | `Makefile` + `test/` | 15 | ✅ |
| `data_structures_advanced` | [07_Data_Structures_Advanced](https://yorche3.github.io/programming_languages/core/algorithms/07_Data_Structures_Advanced/) | — | — | 📋 |
| `efficient_sort` | [08_Efficient_Sort](https://yorche3.github.io/programming_languages/core/algorithms/08_Efficient_Sort/) | — | — | 📋 |
| `distributed_sort` | [09_Distributed_Sort](https://yorche3.github.io/programming_languages/core/algorithms/09_Distributed_Sort/) | — | — | 📋 |
| `searching` | [10_Searching](https://yorche3.github.io/programming_languages/core/algorithms/10_Searching/) | — | — | 📋 |

> **ES:** Los módulos se listan en el orden canónico de la numeración `05_` a `10_`. Los pendientes se documentan al implementarse.
> **EN:** Modules are listed in the canonical order of the `05_` to `10_` numbering. Pending ones are documented as they are implemented.

---

## 🛠️ Patrón común / Common Pattern

| Característica | Descripción |
|---------------|-------------|
| **Sin libc** | Punto de entrada `_start`, no `main`. Solo `syscall`. |
| **NASM Intel syntax** | Todos los fuentes usan sintaxis Intel (NASM), `-f elf64`. |
| **Ejecutable estático** | Enlazado con `ld -m elf_x86_64`; sin librerías dinámicas. |
| **Contrato** | Los `%define` y los `struc` viven en un `.inc` que se incluye con `%include`; cada `.asm` declara en su `global` lo que implementa. |
| **Inclusión** | El `Makefile` pasa `-I$(SRC_DIR)/` y `-I$(TEST_DIR)/`, que es lo que resuelve los `%include`. |
| **Unidad de traducción** | Un `.asm` por unidad lógica; el `wildcard` del `Makefile` genera un objeto por fichero. |
| **Memoria** | Sin libc no hay `malloc`: el módulo que la necesita trae su propio heap sobre `brk`. |
| **Código de salida** | `0` en éxito, número de fallos en las pruebas. |

---

## 🚀 Compilación rápida / Quick Build

```bash
# Naive Sort
cd naive_sort && make

# Data Structures Basics
cd ../data_structures_basics && make
```

---

## ▶️ Siguiente / Next

👉 Continúa con los módulos pendientes de esta fase en el [Roadmap](https://yorche3.github.io/programming_languages/ROADMAP/).

👉 Continue with the pending modules of this phase in the [Roadmap](https://yorche3.github.io/programming_languages/ROADMAP/).

---

*[← Volver a Core](../README.md)*

*🌐 [github.com/yorche3/programming_languages](https://github.com/yorche3/programming_languages) · [GitHub Pages](https://yorche3.github.io/programming_languages/)*
