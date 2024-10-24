# Circuito
![Captura de tela 2024-10-24 183554](https://github.com/user-attachments/assets/7c4b8bca-ae38-45d5-842f-0924fe8fdb6c)


# Defina o estado marcado
Primeiro, você define qual entrada está tentando encontrar na pesquisa. Para fazer isso, escreva uma operação que aplique as etapas b, c e d do algoritmo de Grover.
```qsharp
operation ReflectAboutMarked(inputQubits : Qubit[]) : Unit {
    Message("Reflecting about marked state...");
    use outputQubit = Qubit();
    within {
        // We initialize the outputQubit to (|0⟩ - |1⟩) / √2, so that
        // toggling it results in a (-1) phase.
        X(outputQubit);
        H(outputQubit);
        // Flip the outputQubit for marked states.
        // Here, we get the state with alternating 0s and 1s by using the X
        // operation on every other qubit.
        for q in inputQubits[...2...] {
            X(q);
        }
    } apply {
        Controlled X(inputQubits, outputQubit);
    }
}
```

# Defina o número de iterações ideais
A pesquisa de Grover tem um número ideal de iterações que produz a maior probabilidade de medir uma saída válida. Se o problema tiver N = 2^n possíveis itens elegíveis, e M deles são soluções para o problema, o número ideal de iterações é:
```qsharp
function CalculateOptimalIterations(nQubits : Int) : Int {
    if nQubits > 63 {
        fail "This sample supports at most 63 qubits.";
    }
    let nItems = 1 <<< nQubits; // 2^nQubits
    let angle = ArcSin(1. / Sqrt(IntAsDouble(nItems)));
    let iterations = Round(0.25 * PI() / angle - 0.5);
    return iterations;
}
```
# Defina a operação do Grover
A operação Q# para o algoritmo de pesquisa de Grover tem três entradas:
- O número de qubits, nQubits: Int, no registro de qubit. Este registrador codificará a solução provisória para o problema de pesquisa. Após a operação, será medido.
- O número de iterações ideais, iterações: Int.
- Uma operação, phaseOracle : Qubit[] => Unit) : Result[], que representa o oráculo de fase para a tarefa de Grover. Esta operação aplica uma transformação unitária em um registro qubit genérico.
