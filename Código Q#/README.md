# Como Rodar?
#### 1. Certifique-se de que a extensão está instalada
![image](https://github.com/user-attachments/assets/e643830d-b80e-4d6e-b569-09dc8f14296d)

2. #### Crie um arquivo no seguinte formato
```
Exemplo.qs 
```

3. ### Cole o código, se a extensão estiver corretamente instalada devem aparecer as seguintes opções
![image](https://github.com/user-attachments/assets/866a3306-4d80-4665-9d4a-ee5c38ca60df)
    1. Rodar o Código
    2.
    3.
    4.Criar o Circuito

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
```qsharp
operation GroverSearch( nQubits : Int, iterations : Int, phaseOracle : Qubit[] => Unit) : Result[] {

    use qubits = Qubit[nQubits];
    PrepareUniform(qubits);

    for _ in 1..iterations {
        phaseOracle(qubits);
        ReflectAboutUniform(qubits);
    }

    // Measure and return the answer.
    return MResetEachZ(qubits);
}
```
A operação GroverSearch inicializa um registro de n qubits no estado |0>, prepara o registro em uma superposição uniforme e então aplica o algoritmo de Grover para o número especificado de iterações. A pesquisa em si consiste em refletir repetidamente sobre o estado marcado e o estado inicial, que você pode escrever em Q# como um loop for. Por fim, mede o registrador e retorna o resultado.

O código faz uso de três operações auxiliares: PrepareUniform, ReflectAboutUniform e ReflectAboutAllOnes.

Dado um registro no estado totalmente zero, a operação PrepareUniform prepara uma superposição uniforme sobre todos os estados básicos.
```qsharp
operation PrepareUniform(inputQubits : Qubit[]) : Unit is Adj + Ctl {
    for q in inputQubits {
        H(q);
    }
}
```

A operação ``ReflectAboutAllOnes` reflete sobre o estado de todos.
```qsharp
operation ReflectAboutAllOnes(inputQubits : Qubit[]) : Unit {
    Controlled Z(Most(inputQubits), Tail(inputQubits));
}
```
A operação ReflectAboutUniform reflete sobre o estado de superposição uniforme. Primeiro, transforma a superposição uniforme em zero. Em seguida, ele transforma o estado totalmente zero em todos uns. Por fim, reflete sobre o estado de todos. A operação é chamada ReflectAboutUniform porque pode ser interpretada geometricamente como uma reflexão no espaço vetorial sobre o estado de superposição uniforme.
```qsharp
operation ReflectAboutUniform(inputQubits : Qubit[]) : Unit {
    within {
        Adjoint PrepareUniform(inputQubits);
        // Transform the all-zero state to all-ones
        for q in inputQubits {
            X(q);
        }
    } apply {
        ReflectAboutAllOnes(inputQubits);
    }
}
```
# Execute o código final
Agora você tem todos os ingredientes para implementar uma instância específica do algoritmo de busca de Grover e resolver o problema de fatoração. Para finalizar, a operação Main configura o problema especificando o número de qubits e o número de iterações
```qsharp
operation Main() : Result[] {
let nQubits = 5;
let iterations = CalculateOptimalIterations(nQubits);
Message($"Number of iterations: {iterations}");

// Use Grover's algorithm to find a particular marked state.
let results = GroverSearch(nQubits, iterations, ReflectAboutMarked);
return results;
}
```
