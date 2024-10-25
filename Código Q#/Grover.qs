namespace SingleQubitDeutschJozsa {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Measurement;

    // Função que aplica o oráculo
    operation DeutschJozsaOracle(qubits : Qubit[], oracleType : Bool) : Unit {
        if (oracleType) {
            // Oráculo balanceado: inverte o qubit auxiliar se o valor de entrada for 1
            CNOT(qubits[0], qubits[1]); // Controla o qubit auxiliar
        }
        // Para oráculos constantes, não fazemos nada (identidade)
    }

    // Função principal do algoritmo Deutsch-Jozsa para um qubit de entrada e um qubit auxiliar
    operation DeutschJozsaAlgorithm(oracleType : Bool) : Result {
        use qubits = Qubit[2]; // Inicializa 2 qubits: 1 de entrada + 1 auxiliar

        // Inicializa o qubit auxiliar no estado |1>
        X(qubits[1]); // Aplica X no qubit auxiliar

        // Aplica Hadamard ao qubit de entrada
        H(qubits[0]); // O qubit vai para o estado |+>

        // Aplica Hadamard ao qubit auxiliar
        H(qubits[1]); // O qubit auxiliar vai para o estado |+>

        // Aplica o oráculo
        DeutschJozsaOracle(qubits, oracleType);

        // Aplica Hadamard novamente ao qubit de entrada
        H(qubits[0]);

        // Mede o qubit de entrada
        let result = M(qubits[0]); // Medição do qubit de entrada

        // Resetar os qubits (opcional, dependendo do seu caso de uso)
        ResetAll(qubits);

        // Retornar o resultado da medição
        return result;
    }

    @EntryPoint()
    operation RunSingleQubitDeutschJozsa() : Unit {
        // Teste com oráculo balanceado
        Message("Testando a função com um oráculo balanceado:");
        let result1 = DeutschJozsaAlgorithm(true);  // Oráculo balanceado
        Message($"Oráculo: Balanceado - Medição: {result1}");
    }
}
