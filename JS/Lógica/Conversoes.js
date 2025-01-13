/*

## **Resumo: Tabela de Conversões**

| **Para Tipo**  | **Método**                      | **Exemplo**                          |
|-----------------|---------------------------------|--------------------------------------|
| **String**      | `String(valor)`                | `String(123)` → `"123"`             |
|                 | `valor.toString()`             | `(123).toString()` → `"123"`        |
| **Número**      | `Number(valor)`                | `Number("123")` → `123`             |
|                 | `parseInt(valor, base)`        | `parseInt("42", 10)` → `42`         |
|                 | `parseFloat(valor)`            | `parseFloat("3.14")` → `3.14`       |
|                 | `+valor`                       | `+"123"` → `123`                    |
| **Booleano**    | `Boolean(valor)`               | `Boolean(1)` → `true`               |
|                 | `!!valor`                      | `!!""` → `false`                    |
| **Data**        | `new Date(valor)`              | `new Date("2025-01-13")` → `Date`   |
| **Array**       | `Array.from(iterável)`         | `Array.from("abc")` → `["a", "b", "c"]` |
|                 | `valor.split(delimitador)`     | `"a,b".split(",")` → `["a", "b"]`   |
| **JSON**        | `JSON.parse(jsonString)`       | `JSON.parse('{"a":1}')` → `{a:1}`   |
|                 | `JSON.stringify(objeto)`       | `JSON.stringify({a:1})` → `'{"a":1}'` |

*/